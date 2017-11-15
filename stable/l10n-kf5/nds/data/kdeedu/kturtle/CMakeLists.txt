
install( FILES  logohighlightstyle.nds.xml DESTINATION ${DATA_INSTALL_DIR}/katepart/syntax )
FILE(GLOB datafiles *.logo)
install( FILES ${datafiles} DESTINATION ${DATA_INSTALL_DIR}/kturtle/examples/nds )
