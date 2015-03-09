class ParserController < ApplicationController
	def new

	end

	def run
		parser = Parser.new(params[:data]) 
		if parser.run
			@results = parser.to_html_table
		else
			flash[:error] = "Unable to parse the input data"
		end
		render 'parser/new'
	end
end
