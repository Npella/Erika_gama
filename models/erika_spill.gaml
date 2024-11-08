/**
* Name: NewModel
* Based on the internal skeleton template. 
* Author: Nolwenn
* Tags: 
*/

model erika_spill

global {
	//definiton of the file to import
	file grid_data <- grid_file("../includes/eastward.tif");

	//computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_data);	
	
	float max_value;
	float min_value;
	init {
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		ask cell {
			int val <- int(255 * ( 1  - (grid_value - min_value) /(max_value - min_value)));
			color <- rgb(val,val,val);
		}
	}
}

//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
grid cell file: grid_data;

experiment show_example type: gui {
	output {
		display test axes:false type:3d{
			camera 'default' location: {16384.6813,51385.7828,15210.911} target: {15510.9655,18019.9225,0.0};
			grid cell border: #black elevation:grid_value*5 triangulation:true;
		}
	} 
}
