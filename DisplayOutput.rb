module DisplayOutput

  def DisplayOutput.app_header
    puts "\n"
    puts " DFBC - v 10.0 "
    puts "---------------"
  end

  def DisplayOutput.input_parameters
    puts "\n"
    puts "Usage: dfbc -if file.txt -cn 7 -cv \"some_value\""
    puts "\n"    
    puts "Required Parameters:"
    puts "\n"
  
    puts "-if:  input file"    
    puts "-cn:  number of the column to change the value, the first column value
      is 1"        
    puts "-cv:  value that will be changed in the referred column"    
    
    puts "\n"    
    puts "Optional Parameters:"
    puts "\n"    

    puts "-of:  output file, if it's blank, the new file will be called 
      NEW_<input file>"
    puts "-cs:  character for column separator, like \';\'(semicolon)"
    puts "-rn:  number of the row to change the value, the first column value
      is 1. To update all rows, just don't pass this parameter"
    puts "-bh:  by pass the header row(the first) Y or N"
  end

  def DisplayOutput.process_file(basedir, input_file, output_file)
    puts "\n"
    puts "Processing files:"
    puts "\n"
    puts "Input file: #{basedir}/#{input_file}"
    puts "Ouput file: #{basedir}/#{output_file}"    
  end

  def DisplayOutput.debug_input_parameters params
    puts("\n")
    puts("##### INPUT PARAMS #####")
    puts("\n")

    puts("-if value*: #{params["base_directory"]}/#{params["input_file"]} (#{params["input_file"].class})")
    puts("-of value : #{params["base_directory"]}/#{params["output_file"]} (#{params["output_file"].class})")
    puts("-cs value : #{params["column_separator"]} (#{params["column_separator"].class})")
    puts("-cn value*: #{params["column_number"]} (#{params["column_number"].class})")
    puts("-rn value*: #{params["row_number"]} (#{params["row_number"].class})")
    puts("-bh value*: #{params["bypass_header"]} (#{params["bypass_header"].class})")
    puts("-cv value*: #{params["column_value"]} (#{params["column_value"].class})")

    puts("\nIs the params okay? #{params["valid_params"]}")
  end

  def DisplayOutput.show_error(id, value)
    
    puts "\n"
    puts "--------------------------------------------------"
    
    case id
      when :error_number_args
        puts "# ERROR: Invalid number of arguments and values"
      when :error_required_params
        puts "# ERROR: Missing required parameters: #{value}"
      when :error_invalid_params
        puts "# ERROR: Invalid number of parameters: #{value}"                
      when :error_input_file
        puts "# ERROR: Input File not found: #{value}"
      when :error_output_file
        puts "# ERROR: Invalid Output File: #{value}"                
      when :error_column_number
        puts "# ERROR: Invalid Column Number: #{value}"
      when :error_column_not_found
        puts "# ERROR: Column Number not found: #{value}"        
      when :error_column_value
        puts "# ERROR: Invalid Column Value: #{value}"
      when :error_row_not_found
        puts "# ERROR: Row Number not found: #{value}"
      else 
        puts "# ERROR: Shit happens!"
    end      

    puts "--------------------------------------------------"
    puts "\n"

  end

end