/**
* Name: Erika Spill Model
* Based on the internal skeleton template. 
* Author: Nolwenn
* Tags: 
*/

model erika_spill

global {
	//definiton of the file to import
	file grid_east <- grid_file("../includes/eastward_current.tif");
	file grid_north <- grid_file("../includes/northward_current.tif");
	file wind <- csv_file("../includes/Wind_Belle_Ile_121999_012000_daily_averages.csv");
	image_file img_erika <- image_file("../includes/img/erika_wreck.png");
	//computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_east);
	//step of the simulation to 1 min
	float step <- 1 #minute;
	//initialisation the parameter of the simulation
	float max_value;
	float min_value;
	int nb_petroleum;
	int time_petroleum ;	
	//create a matrix for the wind tab
    matrix tab_wind <- matrix(wind);
    //get the column who we want
    list<float> lst_speed_wind <- tab_wind column_at 2;
    list<float> lst_direction_wind <- tab_wind column_at 1;
    
	init {
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		ask cell {			
			//find if the cell is an ocean or a land, 255 = land and remain ocean
			int val <- (int(255 * ( 1  - (bands[0] - min_value) /(max_value - min_value)))<255) ? int(255 * ( 1  - (bands[1] - min_value) /(max_value - min_value))):255;
			current_north <- bands[0];
			current_east <- bands[1];
			//color the map blue for the ocean and gray for the land
			color <- (val<255)? #blue : #lightgray;
			//create petroleum around the erika
			if (name = "cell2654"){
				create petroleum number:nb_petroleum/(time_petroleum*60){
					location <- {myself.location.x+rnd(-100000,100000), myself.location.y + rnd(-100000,100000)};
				}
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
		//take the value of the wind for the good day
		wind_sp <- lst_speed_wind[day];
		heading_wind <- lst_direction_wind[day];		
		ask mycell
		{
			if (mycell.color != #lightgrey)
			{
				// Calculation of the current angle 
			    angle <- atan2(self.current_north, self.current_east);
			    //Calculation speed of the agent
				myself.speed <- (sqrt(wind_sp^2)* 0.03 + sqrt(self.current_east^2+self.current_north^2));
				//Calculation heading of the agent
				myself.heading <- (angle + heading_wind*0.1+rnd(-50,50))/2.1;				
			}else{
				myself.speed <- 0.0;
			}			
		}
		do move;
	}	
	aspect base {
		geometry var <- circle(2000);
		draw var color: #black;
	}		
}

species erika_wreck {		
	//Create petroleum after the first cycle
	reflex produce_petrol when: cycle <(time_petroleum*60){
		if nb_petroleum/(time_petroleum*60)<1
		{
			if flip(nb_petroleum/(time_petroleum*60))
			{
				create petroleum number:1{
				location <- {myself.location.x+rnd(-10000,10000), myself.location.y + rnd(-10000,10000)};
				}			
			}		
			else
			{
				create petroleum number:nb_petroleum/(time_petroleum*60){
				location <- {myself.location.x+rnd(-10000,10000), myself.location.y + rnd(-10000,10000)};				
				}			
			}
		}
	}	
	aspect base {
		draw img_erika size: 13000;
	}	
}
//grid of the map who contain all the information about the current
grid cell files: [grid_north, grid_east]{
	float current_north;
	float current_east;
}

experiment show_example type: gui {
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
