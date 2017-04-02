class getpcuser
	def getpcusername {
		aname = ENV.["username"]
		name = aname.split(" ")
		return name
	}
end