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
	image_file img_erika <- image_file("../includes/img/erika_wreck.png");
	//computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_east);
	float step <- 1 #minute;
	
	float max_value;
	float min_value;
	int nb_petroleum;

	int time_petroleum ;

	
	file wind <- csv_file("../includes/Wind_Belle_Ile_121999_012000_daily_averages.csv");
    matrix tab_wind <- matrix(wind);
    list<float> lst_speed_wind_north <- tab_wind column_at 4;
    list<float> lst_speed_wind_east <- tab_wind column_at 3;
    list<float> lst_direction_wind <- tab_wind column_at 1;
	init {
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		ask cell {

			int val <- (int(255 * ( 1  - (bands[0] - min_value) /(max_value - min_value)))<255) ? int(255 * ( 1  - (bands[1] - min_value) /(max_value - min_value))):255;

			current_north <- bands[0];
			current_east <- bands[1];
			color <- (val<255)? #blue : #lightgray;
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
		float wind_spn;
		float wind_spe;
		float angle;
		float angle_degrees;
		float heading_wind;
		
		cell mycell;
		
		mycell <- cell closest_to self;

		int day <- int(17 + cycle/1440);
		
		wind_spn <- lst_speed_wind_north[day];
		wind_spe <- lst_speed_wind_east[day];
		heading_wind <- lst_direction_wind[day];
		
		ask mycell
		{
			if (mycell.color != #lightgrey)
			{
				// Calcul de l'angle en radians
			    angle <- atan2(self.current_north, self.current_east);
				myself.speed <- (sqrt(wind_spe^2)* 0.03 + sqrt(self.current_east^2+self.current_north^2));
				myself.heading <- (angle + heading_wind*0.03+2*rnd(-60,60))/3.03 ;
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
	reflex current_move 
	{
		cell mycell;
		mycell <- cell closest_to self;
		
		ask mycell
		{
			if (mycell.color != #lightgrey)
			{
				myself.location <- {(self.current_east*20 + myself.location.x), self.current_north*20 + myself.location.y };

			}
			
		}
		//si on est à un tour ok, on créer un certain nombre de oil spill
		
			if cycle <(time_petroleum*60)
			{
				if nb_petroleum/(time_petroleum*60)<1
				{
					if flip(nb_petroleum/(time_petroleum*60))
					{
						create petroleum number:1{
						location <- {myself.location.x+rnd(-20000,20000), myself.location.y + rnd(-20000,20000)};
					
					}
					
				}
				else
				{
					create petroleum number:nb_petroleum/(time_petroleum*60){
					location <- {myself.location.x+rnd(-20000,20000), myself.location.y + rnd(-20000,20000)};
					
				}
				
			}
			
		
	}
	}
	}
	
	aspect base {
		draw img_erika size: 13000;
	}	



}

//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
//grid cell file: grid_data;
grid cell files: [grid_north, grid_east]{
	float current_north;
	float current_east;
}

experiment show_example type: gui {
	parameter "Nombre d'unité de pétrole" var: nb_petroleum <-400 category: "Pétrole";
	parameter "Temps d'écoulement du pétrole en tout (en heure)" var: time_petroleum <- 48 category: "Pétrole";
	output {
		display test axes:false type:2d{
			grid cell border: #lightgrey elevation:grid_value*5 triangulation:true;
			species erika_wreck aspect:base;
			species petroleum aspect:base;
			
		
}
}
}
