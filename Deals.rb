# require 'sqlite3'

class Deals
	
	attr_accessor :name, :priceHistory, :time, :cat
	
	def initialize(name, priceHist, cat)
			@name = name			
			@time = Time.new
			if priceHist.is_a? Hash
				@priceHistory = priceHist
			end
			@cat = cat
	end

	def updatePrice(price)
		@time = Time.now
		@priceHistory[@time] = price
	end

	def showHist()
		puts @priceHistory
	end

	def showHistLength()
		puts @priceHistory.length
	end

end


