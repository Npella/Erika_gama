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
	
	float max_value;
	float min_value;
	init {
		
		
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		ask cell {
			int val <- int(255 * ( 1  - (bands[0] - min_value) /(max_value - min_value)));
			courant_nord <- bands[0];
			courant_east <- bands[1];
			color <- (val<255)? #blue : #lightgray;
			if (name = "cell2654"){
				color <- #brown;
				create petroleum number:1{
					location <- {myself.location.x+rnd(-10000,10000), myself.location.y + rnd(-10000,10000)};
				}
			}
		}		
	}
}

species petroleum skills: [moving]{
	
	
	
	aspect base {
		geometry var <- circle(2000);
		draw var color: #black;
	}	
}

//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
//grid cell file: grid_data;
grid cell files: [grid_north, grid_east]{
	float courant_nord;
	float courant_east;
}

experiment show_example type: gui {
	output {
		display test axes:false type:2d{
			grid cell border: #lightgrey elevation:grid_value*5 triangulation:true;
			species petroleum aspect:base;
		}
	} 
}
