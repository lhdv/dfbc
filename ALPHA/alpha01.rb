###############################################################################
#
# TODO
#
# (09/26) Maybe a changelog might be a good idea. 
#         Like: Line01:Column05 OldValue = "abc" NewValue = "123"
# (10/02) Directive to output debug and log info
#
# DONE
#
# (09/26-09/26) Decide if the @row_number will be 0 or nil when it wasn't 
#               informed
# (09/27-09/27) Bug when the input file has blank lines
# (09/26-09/27) Inform the user which parameter got error and why(?)
# (09/26-09/27) A new parameter the begin the changes based on a row number
# (09/27-10/01) Do a new function to validate_input_parameter_values, to check 
#               if the -cn exists in the file and other stuff
# (10/01-10/02) Handle directories in Input and Output Files
#
###############################################################################
require 'csv'

class Alpha01

  attr_accessor :valid_input_parameters, :req_input_parameters,
                :input_file, :output_file, :base_directory,
                :column_separator, :column_number, :row_number, :column_value,
                :bypass_header
  
  #############################################################################
  #
  # initialize      
  #
  # desc   : Init all the damn things
  # input  : None
  # output : None
  #
  #############################################################################
  def initialize
    @valid_input_parameters = ["-if","-of","-cs","-cn","-rn","-bh","-cv"]
    @req_input_parameters = ["-if","-cn","-cv"]
  end # end initialize

  #############################################################################
  #
  # exit_no_parameters      
  #
  # desc   : Output the available parameters
  # input  : None
  # output : None
  #
  #############################################################################
  def exit_no_parameters      
    puts "\n=================="
    puts " Input Parameters"
    puts "==================\n\n"
  
    puts "-if: input file (*REQUIRED*)"
    puts "-of: output file, if it's blank, the new file will be called 
     NEW_<input file>"
    puts "-cs: character for column separator"
    puts "-cn: number of the column to change the value, the first column value
     is 1 (*REQUIRED*)"
    puts "-rn: number of the row to change the value, the first column value
     is 1. To update all rows, just don't pass this parameter"
    puts "-bh: by pass the header row(the first) Y or N"
    puts "-cv: value that will be changed in the referred column (*REQUIRED*)"
  end # end exit_no_parameters

  #############################################################################
  #
  # validate_input_parameters
  #
  # desc   : Validate the input parameter(by command-line):
  #          1 - Validate if all the parameters passed in matches the valid 
  #               parameters
  #          2 - Validate if the requided parameter's were passed in
  #          3 - Validate if all the set "parameter + its value" is okay
  #
  # input  : in_params(Array) -> an array with the input parameters from 
  #                              command-line
  # output : valid_params(Boolean) -> if the parameters are okay or not
  #
  #############################################################################
  def validate_input_parameters(in_params)  
    valid_params = false
    
    ###########################################################################
    # Try to parse the input parameters into a Hash where the key is the
    # parameter name. E.g.: {"-if" => "foo.txt"}
    ###########################################################################
    begin    
      
      p = Hash[*in_params]  
    
    rescue ArgumentError => e
      puts("##################################################")
      puts("#                                                #")
      puts("# ERROR: Invalid number of arguments and values! #")
      puts("#                                                #")
      puts("##################################################\n")
      exit_no_parameters
      return valid_params          
    rescue Exception => e
      puts(e.class)
      puts(e)
      return valid_params
    end      
  
    ###########################################################################    
    # Check if there is no 'strange' parameters passed in
    ###########################################################################
    valid_params = p.keys.all? { |pk| valid_input_parameters.include? pk }    
    if( valid_params )    
    
      #######################################################################
      # Check if all the required parameters were passed in and are valid
      #######################################################################
    	valid_params = req_input_parameters.all? { |rp| p.keys.include? rp }    	
    	if( valid_params )
    	
    	  #
    	  # -if validation: check if the file exists
    	  #
    	  valid_params = File.exist?(p["-if"])
    	  if( valid_params )
	    
	        @input_file = File.basename(p["-if"])
          @base_directory = File.dirname(p["-if"])
	    
    	    #
    	    # -cn validation: must be a unsigned number
    	    #
    	    valid_params = ( p["-cn"] =~ /[0-9]/ ) != nil
    	    if( valid_params )
    	    
    	      @column_number = p["-cn"].to_i
    	          	      
    	      #
    	      # -cv validation: must be a value different from nil
    	      #
    	      valid_params = p["-cv"] != nil
    	      if( valid_params )

    	        @column_value = p["-cv"]

    	      else
              
              puts "\n--------------------------------------------------"
              puts "# ERROR: Invalid Column Value: #{p["-cv"]}"
              puts "--------------------------------------------------\n"
              return valid_params

    	      end    	      

    	    else
            
            puts "\n--------------------------------------------------"
            puts "# ERROR: Invalid Column Number: #{p["-cn"]}"
            puts "--------------------------------------------------\n"
            return valid_params

    	    end

        else
          
          puts "\n--------------------------------------------------"
          puts "# ERROR: Input File not found: #{p["-if"]}"
          puts "--------------------------------------------------\n"
          return valid_params

    	  end    	  
    

    	  #####################################################################
    	  # Check the optional parameters
    	  #####################################################################

    	  #
    	  # -of validation: check if there is a extension on file's name
    	  #                 if it's not passed in the default will be 
    	  #                 "NEW_" + @input_file
    	  #
    	  if( p.has_key?("-of") )
    	  
    	    valid_params = !File.extname(p["-of"]).empty?
    	    if( valid_params )
    	      @output_file = p["-of"]
          else

            puts "\n--------------------------------------------------"
            puts "# ERROR: Invalid Output File: #{p["-of"]}"
            puts "--------------------------------------------------\n"
            return valid_params            

    	    end

    	  else
    	    @output_file = "NEW_" + @input_file
    	  end
    	  
    	  #
    	  # -cs validation: check if it's a character and is like 
    	  #                 "," / ";" / "@" / "#" / "\t". 
    	  #                 If it's not passed in the default will be ";"
    	  #
    	  if( p.has_key?("-cs") )    	  
    	  
    	    valid_params = ( p["-cs"] =~ /[,;\@#]/ ) != nil    	    
    	    if( valid_params )
    	      @column_separator = p["-cs"]    	    
    	    else
    	      @column_separator = ";"
    	    end
    	  
    	  else
    	    @column_separator = ";"
    	  end    	  
    	  
  	    #
    	  # -rn validation: must be a unsigned number. If it's not passed in 
    	  #                 the default will be nil
    	  #
    	  if (p.has_key?("-rn") )

    	    valid_params = ( p["-rn"] =~ /[1-9]/ ) != nil
    	    if( valid_params )    	    
    	      @row_number = p["-rn"].to_i
    	    else
    	      @row_number = nil
          end

   	    end

        #
        # -bh validation: must be 0 or 1 oy Y oy N or y oy n
        #
        if (p.has_key?("-bh") )

          valid_params = ( p["-bh"] =~ /[01YNyn]/ ) != nil
          if( valid_params )          
            
            if( ( p["-bh"] =~ /[1Yy]/ ) != nil )
              @bypass_header = true
            else
              @bypass_header = false
            end            

          else
            @bypass_header = false
          end

        else
          @bypass_header = false
        end   	  

    	else

          puts "\n--------------------------------------------------"
          puts "# ERROR: Missing required parameters: #{req_input_parameters}"
          puts "--------------------------------------------------\n"        
          return valid_params

    	end # end required parameters

    else

      puts "\n--------------------------------------------------"
      puts "# ERROR: Wrong number of parameters: #{p.keys}"
      puts "--------------------------------------------------\n"
      return valid_params
    
    end # end valid parameters
    
    puts("\n#####\@ PARAMS \@#####\n")
    puts("-if value*: #{@base_directory}/#{@input_file}(#{@input_file.class})")
    puts("-of value : #{@base_directory}/#{@output_file}(#{@output_file.class})")
    puts("-cs value : #{@column_separator} (#{@column_separator.class})")
    puts("-cn value*: #{@column_number} (#{@column_number.class})")
    puts("-rn value*: #{@row_number} (#{@row_number.class})")    
    puts("-bh value*: #{@bypass_header} (#{@bypass_header.class})")    
    puts("-cv value*: #{@column_value} (#{@column_value.class})")
    puts("\nIs the params okay? #{valid_params}")
    
    valid_params
  end # end def validate_input_parameters
  
  #############################################################################
  #
  # validate_input_parameter_values
  #
  # desc   : validate if all the parameters have valid valeus
  #
  # input  : file(File) -> input_file openned
  # output : None
  #
  #############################################################################
  def validate_input_parameter_values(file)
    
    valid_param_value = false

    #
    # -cn validation
    #
    line_value = file.sample
    if ( file.at(@column_number-1) != nil )
      valid_param_value = true
    else
      puts "\n--------------------------------------------------"
      puts "# ERROR: Column Number not found:  #{@column_number}"
      puts "--------------------------------------------------\n"
    end

    #
    # -rn validation
    #    
    if( @row_number != nil )
      if ( file.at(@row_number-1) != nil )
        valid_param_value = true
      else
        puts "\n--------------------------------------------------"
        puts "# ERROR: Row Number not found : #{@row_number}"
        puts "--------------------------------------------------\n"
      end    
    end

    valid_param_value
  end # end def validate_input_parameter_values

  #############################################################################
  #
  # process_file
  #
  # desc   : Open the @input_file read it, change it and finish it
  #
  # input  : None
  # output : None
  #
  #############################################################################
  def process_file
    init_file_path = "#{@base_directory}/#{@input_file}"
    file = CSV.read(init_file_path,
                    {:col_sep => @column_separator})
        
    puts "# PROCESS FILE #"
    puts " "
    puts "Input File: #{@base_directory}/#{@input_file}"
    puts "Ouput File: #{@base_directory}/#{@output_file}"

    ###########################################################################
    # Call a function to validate the parameter's value
    ###########################################################################
    if( validate_input_parameter_values(file) )

      #########################################################################
      # Check if the changes will be made on all lines or only one
      #########################################################################
      if( @row_number == nil )      

        for i in (0..file.length-1)

          #puts "-- #{file.at(i).at(@column_number-1)} <= #{@column_value}"
          if( (@bypass_header == true && i>0) || @bypass_header == false )
            
            if( file.at(i)[@column_number-1] != nil )
              file.at(i)[@column_number-1] = @column_value          
            end

          end
          
        end

      else
          
        #puts "-- #{file.at(@row_number-1).at(@column_number-1)} <= #{@column_value}"  
        if( file.at(@row_number-1)[@column_number-1] != nil )
          file.at(@row_number-1)[@column_number-1] = @column_value  
        end
              
      end    

      #
      # Write the output file
      #      
      result_file_path = "#{@base_directory}/#{@output_file}"
      CSV.open(result_file_path, "wb", {:col_sep => @column_separator}) do |f|  

        file.each do |line|
          f << line
          #puts ("-- #{line}")
        end
        
      end # end block write output file      

    end # end if( validate_input_parameter_values(file) )
  end # end def process_file

end # end of class

###############################################################################
# MAIN
###############################################################################
alpha = Alpha01.new
input_params = ARGV

if (input_params.empty?)
  alpha.exit_no_parameters
  exit
end

valid_params = alpha.validate_input_parameters(input_params)

if (valid_params)
  alpha.process_file
end
