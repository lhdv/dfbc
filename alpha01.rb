###############################################################################
#
# TODO
#
# (09/26) Inform the user which parameter got error and why(?)
# (09/26) A new parameter the begin the changes based on a row number
# (09/26) Maybe a changelog might be a good idea. 
#         Like: Line01:Column05 OldValue = "abc" NewValue = "123"
#
# (09/26-09/26) Decide if the @row_number will be 0 or nil when it wasn't 
#               informed
# (09/27-09/27) Bug when the input file has blank lines
###############################################################################

require 'csv'

class Alpha01

  attr_accessor :valid_input_parameters, :req_input_parameters
  attr_accessor :input_file, :output_file, :column_separator, :column_number, 
                :row_number, :column_value
  
  def initialize
    @valid_input_parameters = ["-if","-of","-cs","-cn","-rn","-cv"]
    @req_input_parameters = ["-if","-cn","-cv"]
  end

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
     is 0 (*REQUIRED*)"
    puts "-rn: number of the row to change the value, the first column value
     is 0. To update all rows, just don't pass this parameter"
    puts "-cv: value that will be changed in the referred column (*REQUIRED*)"

  end

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
    	  valid_params = File.exists?(p["-if"])
    	  if( valid_params )
	    
	    @input_file = p["-if"]
	    
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
    	      
    	      end    	      
    	      
    	    end

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
    	      @column_separator = p["-cv"]    	    
    	    else
    	      @column_separator = ";"
    	    end
    	  
    	  else
    	    @column_separator = ";"
    	  end    	  
    	  
  	  #
    	  # -rn validation: must be a unsigned number. If it's not passed in 
    	  #                 the default will be ????
    	  #
    	  if (p.has_key?("-rn") )

    	    valid_params = ( p["-rn"] =~ /[0-9]/ ) != nil
    	    if( valid_params )    	    
    	      @row_number = p["-rn"].to_i
    	    else
    	      @row_number = nil
   	    end
   	  
   	  else
            @row_number = nil
    	  end
    	
    	end # end required parameters
    	
    end # end valid parameters
    
    puts("\n#####\@ PARAMS \@#####\n")
    puts("-if value*: #{@input_file} (#{@input_file.class})")
    puts("-of value : #{@output_file} (#{@output_file.class})")
    puts("-cs value : #{@column_separator} (#{@column_separator.class})")
    puts("-cn value*: #{@column_number} (#{@column_number.class})")
    puts("-rn value*: #{@row_number} (#{@row_number.class})")    
    puts("-cv value*: #{@column_value} (#{@column_value.class})")
    puts("\nIs the params okay? #{valid_params}")
    
    return valid_params

  end
  
#  - open the input_file
#  - check if there is a valid -cn(column number) to change the values,
#    based on the -cs(column separator)
#  - if a -rn(row number) was passed in update just this row, else update
#    all rows

  #############################################################################
  #
  # process_file
  #
  # desc   : Open the @input_file read it, change it and finish it
  #
  # input  : 
  # output : 
  #
  #############################################################################
  def process_file
  
    file = CSV.read(@input_file,{:col_sep => @column_separator})
        
    puts "# PROCESS FILE #"
    puts " "
    puts "Input File: #{@input_file}"
    puts "Ouput File: #{@output_file}"
    
    ###########################################################################
    # Check if the changes will be made on all lines or only one
    ###########################################################################
    if( @row_number == nil )

      for i in (0..file.length-1)

        #puts "-- #{file.at(i).at(@column_number-1)}"
        if( file.at(i)[@column_number-1] != nil )
          file.at(i)[@column_number-1] = @column_value          
        end
        
      end

    else
        
      #puts "-- #{file.at(@row_number-1).at(@column_number-1)}"  
      if( file.at(@row_number-1)[@column_number-1] != nil )

        file.at(@row_number-1)[@column_number-1] = @column_value  
      end
            
    end    

    #puts ("-- #{file}\n")

    CSV.open(@output_file, "wb", {:col_sep => @column_separator}) do |f|  

      file.each do |line|
        f << line
        #puts ("-- #{line}")
      end
      
    end
      
  end

end

###############################################################################
# MAIN
###############################################################################

alpha = Alpha01.new
input_params = ARGV

if(input_params.empty?)
  alpha.exit_no_parameters
  exit
end

params = alpha.validate_input_parameters(input_params)

if ( params )
  alpha.process_file
end

#puts params.class

#s = Array.new
#",123,123,456,456,777,111".lines(",") {|x| s << x.chomp(",")}
#p s
