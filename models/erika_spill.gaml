/**
* Name: NewModel
* Based on the internal skeleton template. 
* Author: Nolwenn
* Tags: 
*/

model erika_spill

global {
	//definiton of the file to import
	file grid_data <- grid_file("../includes/eastward_current.tif");
	file grid_north <- grid_file("../includes/northward_current.tif");

	//computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_data);	
	geometry shape_north <- envelope(grid_north);
	
	float max_value;
	float min_value;
	init {
		create petroleum number:1;
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		ask cell {
			int val <- int(255 * ( 1  - (grid_value - min_value) /(max_value - min_value)));
			color <- (val<255)? #darkblue : #lightgray;
			if (name = "cell2654"){
				color <- #brown;
			}
		}		
	}
}

species petroleum{
	aspect base {
		geometry var <- circle(2000);
		draw var color: #red;
	}	
}


//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
//grid cell file: grid_data;
grid cell file: grid_north;

experiment show_example type: gui {
	output {
		display test axes:false type:2d{
			grid cell border: #black elevation:grid_value*5 triangulation:true;
			species petroleum aspect:base;
		}
	} 
}
