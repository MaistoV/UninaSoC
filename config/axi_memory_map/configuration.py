# Author: Stefano Toscano <stefa.toscano@studenti.unina.it>
# Description: Declaration of wrapper class for configuration properties with their default values (if any). Lists are just initialized as empty.

# Wrapper class for configuration properties
class Configuration:
	def __init__(self): 
		self.PROTOCOL			 : str = "AXI4"	# AXI PROTOCOL used
		self.CONNECTIVITY_MODE	 : str = "SAMD"	# Crossbar Configuration, Shared-Address/Multiple-Data(SAMD) or Shared-Address/Shared-Data(SASD)
		self.ADDR_WIDTH			 : int = 32 	# Address Width
		self.DATA_WIDTH			 : int = 32 	# Data Width
		self.ID_WIDTH			 : int = 4		# ID Data Width for MI and SI (a subset of it is used by the Interfaces Thread IDs)
		self.NUM_MI				 : int = 2 		# Master Interface (MI) Number
		self.NUM_SI				 : int = 1 		# Slave Interface (SI) Number
		self.RANGE_NAMES         : list = []    # List of names of slaves connected to the bus
		self.ADDR_RANGES		 : list = 1 	# Number of Address Ranges for all MI
		self.BASE_ADDR			 : list = [] 	# the Base Address of each Range of each Master
		self.RANGE_ADDR_WIDTH	 : list = [] 	# the width of each Range of each Master
		self.READ_CONNECTIVITY	 : list = [] 	# the enable option for each MI_to_SI possible Connection for Read Operations
		self.WRITE_CONNECTIVITY	 : list = [] 	# the enable option for each MI_to_SI possible Connection for Write Operations
		self.STRATEGY			 : int = 0 		# Implementation strategy, Minimize Area (1), Maximize Performance (2)
		self.R_REGISTER			 : int = 0 		# Internal Registers division
		self.Slave_Priorities	 : list = [] 	# Scheduling Priority for each Slave
		self.SI_READ_ACCEPTANCE	 : list = [] 	# Number of possible Active Read Transaction at the same time for each Slave
		self.SI_WRITE_ACCEPTANCE : list = [] 	# Number of possible Active Write Transaction at the same time for each Slave
		self.THREAD_ID_WIDTH	 : list = [] 	# Number of ID bits used by each SI for thei respective Threads
		self.SINGLE_THREAD		 : list = [] 	# Enable options for each SI in regards to the Single Thread Option
		self.BASE_ID			 : list = [] 	# Base ID for each SI
		self.MI_READ_ISSUING	 : list = [] 	# Number of possible Active Read Transaction at the same time for each Master
		self.MI_WRITE_ISSUING    : list = [] 	# Number of possible Active Write Transaction at the same time for each Master
		self.SECURE				 : list = [] 	# Master SECURE mode
		self.AWUSER_WIDTH		 : int = 0		# AXI AW User width
		self.ARUSER_WIDTH		 : int = 0		# AXI AR User width
		self.WUSER_WIDTH		 : int = 0		# AXI  W User width
		self.RUSER_WIDTH		 : int = 0		# AXI  R User width
		self.BUSER_WIDTH		 : int = 0		# AXI  B User width

