# Author: Stefano Toscano <stefa.toscano@studenti.unina.it>
# Description: Declaration of wrapper class for configuration properties with their default values (if any). Lists are just initialized as empty.

# Wrapper class for configuration properties
class Configuration:
	PROTOCOL			: str = "AXI4"	# AXI PROTOCOL used
	CONNECTIVITY_MODE	: str = "SAMD"	# Crossbar Configuration, Shared-Address/Multiple-Data(SAMD) or Shared-Address/Shared-Data(SASD)
	ADDR_WIDTH			: int = 32 		# Address Width
	DATA_WIDTH			: int = 32 		# Data Width
	ID_WIDTH			: int = 4		# ID Data Width for MI and SI (a subset of it is used by the Interfaces Thread IDs)
	NUM_MI				: int = 2 		# Master Interface (MI) Number
	NUM_SI				: int = 1 		# Slave Interface (SI) Number
	ADDR_RANGES			: list = 1 		# Number of Address Ranges for all MI
	BASE_ADDR			: list = [] 	# the Base Address of each Range of each Master
	RANGE_ADDR_WIDTH	: list = [] 	# the width of each Range of each Master
	READ_CONNECTIVITY	: list = [] 	# the enable option for each MI_to_SI possible Connection for Read Operations
	WRITE_CONNECTIVITY	: list = [] 	# the enable option for each MI_to_SI possible Connection for Write Operations
	STRATEGY			: int = 0 		# Implementation strategy, Minimize Area (1), Maximize Performance (2)
	R_REGISTER			: int = 0 		# Internal Registers division
	Slave_Priorities	: list = [] 	# Scheduling Priority for each Slave
	SI_READ_ACCEPTANCE	: list = [] 	# Number of possible Active Read Transaction at the same time for each Slave
	SI_WRITE_ACCEPTANCE	: list = [] 	# Number of possible Active Write Transaction at the same time for each Slave
	THREAD_ID_WIDTH		: list = [] 	# Number of ID bits used by each SI for thei respective Threads
	SINGLE_THREAD		: list = [] 	# Enable options for each SI in regards to the Single Thread Option
	BASE_ID				: list = [] 	# Base ID for each SI
	MI_READ_ISSUING		: list = [] 	# Number of possible Active Read Transaction at the same time for each Master
	MI_WRITE_ISSUING	: list = [] 	# Number of possible Active Write Transaction at the same time for each Master
	SECURE				: list = [] 	# Master SECURE mode
	AWUSER_WIDTH		: int = 0		# AXI AW User width
	ARUSER_WIDTH		: int = 0		# AXI AR User width
	WUSER_WIDTH			: int = 0		# AXI  W User width
	RUSER_WIDTH			: int = 0		# AXI  R User width
	BUSER_WIDTH			: int = 0		# AXI  B User width

