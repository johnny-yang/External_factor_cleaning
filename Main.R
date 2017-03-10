source('~/External_factor_cleaning/Function.R', echo=TRUE)

Weather_data<-Weather_data_final_version()
Fuel_data<-Fuel_data_final_version()
Stock_Price_Yahoo<-Stock_Yahoo()
Stock_Price_Google<-Stock_Google()
Holiday_Au<-Holiday_data_cleaning("Australia",Developer = F,Date_option=T,"2010-10-10")
Holiday_Cn<-Holiday_data_cleaning("China",Developer = F,Date_option=T,"2010-10-10")
Holiday_In<-Holiday_data_cleaning("India",Developer = F,Date_option=T,"2010-10-10")


write.csv(Weather_data,file = "./Final_data_backup(All cleaned data)/Weather_data.csv",fileEncoding = "gb18030")
write.csv(Fuel_data,file = "./Final_data_backup(All cleaned data)/Fuel_data.csv",fileEncoding = "gb18030")
write.csv(Stock_Price_Yahoo,file = "./Final_data_backup(All cleaned data)/Stock_Price_Yahoo.csv",fileEncoding = "gb18030")
write.csv(Stock_Price_Google,file = "./Final_data_backup(All cleaned data)/Stock_Price_Google.csv",fileEncoding = "gb18030")
write.csv(Holiday_Au,file = "./Final_data_backup(All cleaned data)/Holiday_Au.csv",fileEncoding = "gb18030")
write.csv(Holiday_Cn,file = "./Final_data_backup(All cleaned data)/Holiday_Cn.csv",fileEncoding = "gb18030")
write.csv(Holiday_In,file = "./Final_data_backup(All cleaned data)/Holiday_In.csv",fileEncoding = "gb18030")



# # uploading to MSU database
# mydb = dbConnect(MySQL(), user='MSU_DB_Manager', password='Embarassing...', dbname='ext_factor', host='10.52.96.130', port = 3306)
# 
# message("Start Preparing Database...")
# 
# dbRemoveTable(mydb, "Weather_data")
# dbRemoveTable(mydb, "Fuel_data")
# dbRemoveTable(mydb, "Stock_Price_Yahoo")
# dbRemoveTable(mydb, "Stock_Price_Google")
# dbRemoveTable(mydb, "Holiday")

# dbWriteTable(mydb, "Weather_data", Weather_data)
# dbWriteTable(mydb, "Fuel_data", Fuel_data)
# dbWriteTable(mydb, "Stock_Price_Yahoo", Stock_Price_Yahoo)
# dbWriteTable(mydb, "Stock_Price_Google", Stock_Price_Google)
# dbWriteTable(mydb, "Holiday", Holiday)

# cat("/n")
# dbDisconnect(mydb)
