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
	init {
		
		
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		ask cell {
			int val <- int(255 * ( 1  - (bands[1] - min_value) /(max_value - min_value)));
			current_north <- bands[0];
			current_east <- bands[1];
			color <- (val<255)? #blue : #lightgray;
			if (name = "cell2654"){
				create petroleum number:nb_petroleum/(time_petroleum*60){
					location <- {myself.location.x+rnd(-10000,10000), myself.location.y + rnd(-10000,10000)};
				}
				create erika_wreck number: 1 {location <- {myself.location.x,myself.location.y};}
			}
		}		
	}
}

species petroleum {
	
	reflex current_move 
	{
		cell mycell;
		mycell <- cell closest_to self;
		
		ask mycell
		{
			if (mycell.color != #lightgrey)
			{
				myself.location <- {(self.current_east*60 + myself.location.x), self.current_north*60 + myself.location.y };

			}
			
		}
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
				create petroleum number:nb_petroleum/(time_petroleum*60){
					location <- {myself.location.x+rnd(-8000,8000), myself.location.y + rnd(-8000,8000)};}
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
	parameter "Temps d'écoulement du pétrole en tout (en heure)" var: time_petroleum <- 6 category: "Pétrole";
	output {
		display test axes:false type:2d{
			grid cell border: #lightgrey elevation:grid_value*5 triangulation:true;
			species erika_wreck aspect:base;
			species petroleum aspect:base;
			
		}
	} 
}
