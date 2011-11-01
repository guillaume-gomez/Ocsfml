open System
open Window
open Graphics
open Audio

let pi = 4.0 *. atan 1.0

let load_sound_buffer file_name =
	let sound_buffer = new sound_buffer in
		if sound_buffer#load_from_file file_name
		then sound_buffer
		else failwith ("Could not load sound buffer " ^ file_name)


let load_texture file_name =
	let texture = new texture in
		if texture#load_from_file file_name
		then texture
		else failwith ("Could not load texture " ^ file_name)


let load_font file_name  =
	let font = new font in
		if font#load_from_file file_name
		then font
		else failwith ("Could not load font " ^ file_name)

let test_pong () =
begin
	Random.self_init () ;

	let vm = VideoMode.({ width=800 ; height=600 ; bits_per_pixel=32 }) in
	let app = new render_window vm  "Ocsfml - Pong" in
	
	let font = load_font "resources/sansation.ttf" in
	let ball_texture = load_texture "resources/ball.png" in
	let background_texture = load_texture "resources/background.jpg" in
	let left_paddle_texture = load_texture "resources/paddle_left.png" in 
	let right_paddle_texture = load_texture "resources/paddle_right.png" in
	let ball_sound_buffer = load_sound_buffer "resources/ball.wav" in



	
	let endText = new text in
		endText#set_font font;
		endText#set_character_size 50;
		endText#move 150.0 200.0;
		endText#set_color (Color.rgb 50 50 250) ;
	let background = new spriteCpp (Sprite.create_from_texture background_texture) in
   	let left_paddle = new spriteCpp (Sprite.create_from_texture left_paddle_texture) in
	let right_paddle = new spriteCpp (Sprite.create_from_texture right_paddle_texture) in
	let ball = new spriteCpp (Sprite.create_from_texture ball_texture) in
	let ball_sound = new soundCpp (Sound.create_from_sound_buffer ball_sound_buffer) in
	
	let view = app#get_view () in
	let app_size = view#get_size () in
	let lft_size = left_paddle#get_size () in
	let rgt_size = right_paddle#get_size () in
	let ball_size = ball#get_size () in
	let test = fst app_size -. fst lft_size in

	(*left_paddle#move 10.0 (() /. 2.0) ;
	right_paddle#move 	((fst ((app#get_view ())#get_size ())) -. (fst (right_paddle#get_size ())) -. 10.0) 
						(((snd ((app#get_view ())#get_size ())) -. (snd (right_paddle#get_size ())) ) /. 2.0) ;
	ball#move 	(((fst  ((app#get_view ())#get_size ())) -. (fst  (ball#get_size ()))) /. 2.0)
				(((snd ((app#get_view ())#get_size ())) -. (snd (ball#get_size ()))) /. 2.0) ; *)
	
	let ai_timer = new clock in
	let ai_time = 100 in
	let left_paddle_speed = ref 400.0 in
	let right_paddle_speed = ref 400.0 in
	
	let ball_speed = ref 400.0 in
	let ball_angle =
		let angle = acos ((Random.float 0.3) +. 0.7) in
		ref( if Random.bool () then angle +. pi else angle )
	in
	
	let is_playing = ref true in

	let rec event_loop () =
		match app#poll_event () with
			| Some e ->
				Event.( match e with
					| Closed | KeyPressed { code = KeyCode.Escape ; _ } -> app#close ()
					| _ -> () ) ;
				event_loop ()
			| None -> () 
	in

	let update () =
		if !is_playing 
		then begin
			if is_key_pressed KeyCode.Up && (snd (left_paddle#get_position ()) > 5.0) 
			then left_paddle#move 0.0 (-. !left_paddle_speed *. float_of_int(app#get_frame_time ()) /. 1000.0) ;
			if is_key_pressed KeyCode.Down && (snd (left_paddle#get_position ()) > snd ((app#get_view ())#get_size()) -. snd (left_paddle#get_size ()) -. 5.0) 
			then left_paddle#move 0.0 (!left_paddle_speed *. float_of_int(app#get_frame_time ()) /. 1000.0) ;
		
			if 	(!right_paddle_speed < 0.0 && (snd (right_paddle#get_position ()) > 5.0)) || 
				(!right_paddle_speed > 0.0 && (snd (right_paddle#get_position ()) > snd ((app#get_view ())#get_size()) -. snd (right_paddle#get_size ()) -. 5.0))
			then right_paddle#move 0.0 (!right_paddle_speed *. float_of_int(app#get_frame_time ()) /. 1000.0) ;
		
			if ai_timer#get_elapsed_time () > ai_time
			then begin
				ai_timer#reset ();
				if	(!right_paddle_speed < 0.0) && 
					((snd (ball#get_position ()) +. snd (ball#get_size ()) ) > (snd (right_paddle#get_position ()) +. snd (right_paddle#get_size ())))
				then right_paddle_speed := -. !right_paddle_speed;
				if	(!right_paddle_speed > 0.0) &&
					(snd (ball#get_position ()) < snd (right_paddle#get_position ()))
				then right_paddle_speed := -. !right_paddle_speed
			end;

			(** Update Ball Position **)
			let factor = !ball_speed *. float_of_int (app#get_frame_time ()) /. 1000.0 in
			ball#move ((cos !ball_angle) *. factor) ((sin !ball_angle) *. factor) ;
			if fst (ball#get_position ()) < 0.0
			then begin
				is_playing := false;
				endText#set_string "You lost!\n(press escape to exit)"
			end;
			if (fst (ball#get_position ()) +. fst (ball#get_size ())) > fst ((app#get_view ())#get_size ())
			then begin
				is_playing := false;
				endText#set_string "You lost!\n(press escape to exit)"
			end;
			if snd(ball#get_position ()) < 0.0
			then begin
				ball_sound#play ();
				ball_angle := -. !ball_angle;
				ball#set_y 0.1
			end;
			if (snd(ball#get_position ()) +. snd(ball#get_size ())) > snd ((app#get_view())#get_size())
			then begin
				ball_sound#play ();
				ball_angle := -. !ball_angle;
				ball#set_y  (snd((app#get_view ())#get_size ()) -. snd(ball#get_size ()) -. 0.1)
			end;

			(** Check collision between the paddles and the ball **)
			if 	(fst (ball#get_position ())  < fst (left_paddle#get_position ()) +. fst (left_paddle#get_size ())) &&
				(fst (ball#get_position ())  > fst (left_paddle#get_position ()) +. (fst (left_paddle#get_size ()) /. 2.0)) &&
				(snd (ball#get_position ()) +. snd(ball#get_size ()) >= snd (left_paddle#get_position ())) &&
                (snd (ball#get_position ())							  <= snd (left_paddle#get_position ()) +. snd (left_paddle#get_size()))
			then begin
				ball_sound#play ();
				ball_angle := pi -. !ball_angle;
				ball#set_y  (fst (left_paddle#get_position ()) +. fst (ball#get_size ()) +. 0.1)
			end ;

			if 	(fst (ball#get_position ())  +. fst (ball#get_size ())  >  fst(right_paddle#get_position ())) &&
				(fst (ball#get_position ())  +. fst (ball#get_size ())  <  fst(right_paddle#get_position ()) +. (fst (right_paddle#get_size()) /. 2.0)) &&
				(snd (ball#get_position ())  +. snd (ball#get_size ())  >= snd (right_paddle#get_position ())) &&
				(snd (ball#get_position ()) 							<= snd (right_paddle#get_position ()) +. snd (right_paddle#get_size()))
			then begin
				ball_sound#play ();
				ball_angle := pi -. !ball_angle;
				ball#set_y  (fst(right_paddle#get_position ()) -. fst(ball#get_size ()) -. 0.1)
			end
		end
		
	in			
	
	let draw () =
		app#draw background ;
		app#draw left_paddle ;
		app#draw right_paddle ;
		app#draw ball ;
		if not !is_playing
		then app#draw endText
	in

	let rec main_loop () =
		if app#is_opened()
		then begin
			event_loop ();
		(*	update (); *)
			draw ();
			app#display ();
			main_loop ()
		end
	in
	
	main_loop ();
	ai_timer#destroy ();
	ball_sound#destroy ();
	ball#destroy ();
	right_paddle#destroy ();
	left_paddle#destroy ();
	background#destroy ();
	endText#destroy ();
	ball_sound_buffer#destroy ();
	left_paddle_texture#destroy ();
	right_paddle_texture#destroy ();
	ball_texture#destroy ();
	font#destroy () ;
	app#destroy () ;
	background_texture#destroy ()
end

let _ = test_pong ()

