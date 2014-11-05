FILE(GLOB datafiles *.kvtml)
install( FILES ${datafiles} DESTINATION ${DATA_INSTALL_DIR}/kvtml/nds )
install( FILES  nds.txt  DESTINATION ${DATA_INSTALL_DIR}/khangman )
