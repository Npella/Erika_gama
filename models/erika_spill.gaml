/**
* Name: Erika Spill Model
* Author: Nolwenn PELLARD and Marvin LOUAPRE
* Emails: nolwenn.pellard@isen-ouest.yncrea.fr, marvin.louapre@isen-ouest.yncrea.fr
*/

model erika_spill

global {
	
	// VARIABLES
	// Definiton of the file to import
	file grid_east <- grid_file("../includes/eastward_current.tif");
	file grid_north <- grid_file("../includes/northward_current.tif");
	file wind <- csv_file("../includes/Wind_Belle_Ile_121999_012000_daily_averages.csv");
	image_file img_erika <- image_file("../includes/img/erika_wreck.png");
	// Computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_east);
	// Step of the simulation to 1 min
	float step <- 1 #minute;
	// Initialization the parameter of the simulation
	float max_value;
	float min_value;
	int nb_petroleum;
	int time_petroleum ;	
	// Create a matrix for the wind tab
    matrix tab_wind <- matrix(wind);
    // Get the column who we want
    list<float> lst_speed_wind <- tab_wind column_at 2;
    list<float> lst_direction_wind <- tab_wind column_at 1;
    
    
    
	init {
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		
		ask cell {			
			// Find if the cell is an ocean or a land, 255 = land and remain ocean
			int val <- (int(255 * ( 1  - (bands[0] - min_value) /(max_value - min_value)))<255) ? int(255 * ( 1  - (bands[1] - min_value) /(max_value - min_value))):255;
			current_north <- bands[0];
			current_east <- bands[1];
			
			color <- (val<255)? #blue : #lightgray; // Color the map blue for the ocean and gray for the land
			
			// Create Erika
			if (name = "cell2654"){
				create erika_wreck number: 1 {location <- {myself.location.x,myself.location.y};}
			}
		}		
	}
}


species petroleum skills:[moving]{
		
	reflex current_move 
	{		
		float wind_sp;
		float angle;
		float angle_degrees;
		float heading_wind;		
		cell mycell;
		//cell where the agent is
		mycell <- cell closest_to self;
		//day of the simulation, begin at 18 because erica stranded at this date
		int day <- int(12 + cycle/1440);
		//take the value of the wind for the right day
		wind_sp <- lst_speed_wind[day];
		heading_wind <- lst_direction_wind[day];		
		ask mycell
		{
			if (mycell.color != #lightgrey)
			{
				// Calculation of the current angle 
			    angle <- atan2(-self.current_north, self.current_east);
			    //Calculation speed of the agent
				myself.speed <- (sqrt(wind_sp^2)* 0.03 + sqrt(self.current_east^2+self.current_north^2));
				//Calculation heading of the agent
				myself.heading <- angle*1.6 + heading_wind-360;				
			}else{
				myself.speed <- 0.0;
			}			
		}
		do move;
	}	
	aspect base {
		geometry var <- circle(2000);
		draw var color: #black;}		
}

species erika_wreck {	
		
	//Create petroleum if the flow is still ongoing and if the amount of petroleum is inferior to the expected amount
	reflex produce_petrol when: (cycle<(time_petroleum*60) and (length(petroleum)<nb_petroleum+1))
	{
		float petrol_rate <- nb_petroleum/(time_petroleum*60);//So that the time would be in mn instead of hours
		int nb_petrol_per_turn <- div(nb_petroleum,(time_petroleum*60));// Quotient of the equation
		
		// Probability in accordance to the remains of the equation
		if flip(petrol_rate-div(nb_petroleum, time_petroleum*60))
			{nb_petrol_per_turn <- nb_petrol_per_turn+1;}
			
		// If it's the last cycle and the number of petroleum isn't the same as the expected amount	
		if (cycle = time_petroleum*60-1) and (length(petroleum)+nb_petrol_per_turn <nb_petroleum)
		{nb_petrol_per_turn <- nb_petrol_per_turn + nb_petroleum - length(petroleum)+1;}
		
		// Creation of petroleum agents near the ship wreck
		create petroleum number:(nb_petrol_per_turn){
			location <- {myself.location.x+rnd(-10000,10000), myself.location.y + rnd(-10000,10000)};}
	}
		
	aspect base {draw img_erika size: 13000;}	
}



//grid of the map who contain all the information about the current
grid cell files: [grid_north, grid_east]{
	float current_north;
	float current_east;
}

experiment Erika_Spill_Map type: gui {
	parameter "Nombre d'unité de pétrole" var: nb_petroleum <-100 category: "Pétrole";
	parameter "Temps d'écoulement du pétrole en tout (en heure)" var: time_petroleum <- 48 category: "Pétrole";
	output {
		display test axes:false type:2d{
			grid cell border: #lightgrey elevation:grid_value*5 triangulation:true;
			species erika_wreck aspect:base;
			species petroleum aspect:base;	
		}
	}
}
