function psychsr_calibrate_screen()
% PURPOSE:
%	use the screen size and position to determine the stimulus parameters from the point of view of the animal

	global data;
	
	% a triangle is formed between the mouse, the screen middle, and the screen left
	
	% first, get the "opposite" side of the triangle, which is half the screen
	opposite_side_length = data.screen.width_cm / 2;
	
	% second, get the "adjacent" side of the triangle, the distance from screen to animal
	adjacent_side_length = data.screen.distance_cm;

	% get the visual angle from screen side to center: take the inverse tangent (in degrees) of opposite over adjacent 
	visual_degrees_of_half_screen = atand(opposite_side_length / adjacent_side_length);
	
	% calculate how many pixels are in each degree
	visual_degrees_of_screen = visual_degrees_of_half_screen * 2;
	pixels_per_degree = data.screen.width_pixels / visual_degrees_of_screen;

	% save info in psychsr
	data.screen.width_degrees = visual_degrees_of_screen;
	data.screen.pixels_per_degree = pixels_per_degree;
	
    
%     % first, get the "opposite" side of the triangle, which is half the screen
% 	opposite_side_length = data.screen.height_cm / 2;
% 	
% 	% second, get the "adjacent" side of the triangle, the distance from screen to animal
% 	adjacent_side_length = data.screen.distance_cm;
% 
% 	% get the visual angle from screen side to center: take the inverse tangent (in degrees) of opposite over adjacent 
% 	visual_degrees_of_half_screen = atand(opposite_side_length / adjacent_side_length);
% 	
% 	% calculate how many pixels are in each degree
% 	visual_degrees_of_screen = visual_degrees_of_half_screen * 2;
% 	pixels_per_degree = data.screen.height_pixels / visual_degrees_of_screen;
    
end