/**
* Name: NewModel
* Based on the internal skeleton template. 
* Author: Nolwenn
* Tags: 
*/

model erika_spill

global {
	//definiton of the file to import
	file grid_east <- grid_file("../includes/eastward_current.tif");
	file grid_north <- grid_file("../includes/northward_current.tif");

	//computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_east);
	float step <- 1 #minute;
	
	float max_value;
	float min_value;
	
	file wind <- csv_file("../includes/Wind_Belle_Ile_121999_012000_daily_averages.csv");
    matrix tab_wind <- matrix(wind);
    list<float> lst_speed_wind_north <- tab_wind column_at 4;
    list<float> lst_speed_wind_east <- tab_wind column_at 3;
    list<float> lst_direction_wind <- tab_wind column_at 1;
	init {		
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		ask cell {
			int val <- int(255 * ( 1  - (bands[0] - min_value) /(max_value - min_value)));
			current_north <- bands[0];
			current_east <- bands[1];
			color <- (val<255)? #blue : #lightgray;
			if (name = "cell2654"){
				color <- #brown;
				create petroleum number:100{
					location <- {myself.location.x+rnd(-10000,10000), myself.location.y + rnd(-10000,10000)};
					speed_wind_north <- lst_speed_wind_north;
					speed_wind_east <- lst_speed_wind_east;
					direction_wind <- lst_direction_wind;
				}
			}
		}		
	}
}


species petroleum skills:[moving]{
	list<float> speed_wind_north;
	list<float> speed_wind_east;
	list<float> direction_wind;
	
		
	reflex current_move 
	{		
		float wind_spn;
		float wind_spe;
		int angle;
		float angle_degrees;
		float heading_wind;
		
		cell mycell;
		mycell <- cell closest_to self;
		int day <- 17 + cycle/1440;
		wind_spn <- speed_wind_north[day];
		wind_spe <- speed_wind_east[day];
		heading_wind <- direction_wind[day];

		
		ask mycell
		{
			if (mycell.color != #lightgrey)
			{
				// Calcul de l'angle en radians
			    angle <- atan2(self.current_north, self.current_east);
				myself.speed <- (sqrt(wind_spe^2)* 0.03 + sqrt(self.current_east^2+self.current_north^2));
				myself.heading <- (angle + heading_wind*0.1+rnd(-120,120))/2.1 ;
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


//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
//grid cell file: grid_data;
grid cell files: [grid_north, grid_east]{
	float current_north;
	float current_east;
}

experiment show_example type: gui {
	output {
		display test axes:false type:2d{
			grid cell border: #lightgrey elevation:grid_value*5 triangulation:true;
			species petroleum aspect:base;
		}
	} 
}
