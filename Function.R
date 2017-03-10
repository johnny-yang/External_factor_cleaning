library(dplyr)
library(RMySQL)
library(openxlsx)
library(lubridate)

# ----------------------------------------------------
Weather_Clean_data<-function(path) {
  
  message("Start to Load and Process ",path)
  # read raw data from txt files
  # raw_data<-read.table("./Weather_crawler_Main/Shanghai.txt",fill = TRUE,header = FALSE,sep = "\t",encoding = "UTF-8",stringsAsFactors = F)
  raw_data<-read.table(path,fill = TRUE,header = FALSE,sep = "\t",encoding = "UTF-8",stringsAsFactors = F)
  # data cleaning
  raw_data<-filter(raw_data,raw_data$V1!="Here comes another month")
  city<-raw_data[[1]][1]
  raw_data<-filter(raw_data,raw_data$V1!=city)
  # add time to each row
  tem<-raw_data[[1]][1]
  for  (i in 1:length(raw_data[[1]])){
    if (raw_data[[1]][i]=='') 
      raw_data[[1]][i]<-tem
    else tem<-raw_data[[1]][i]
  }
  raw_data<-filter(raw_data,raw_data$V3!="")
  raw_data<-as.data.frame(raw_data)
  #deal with time
  raw_data$V1<-as.character(raw_data$V1)
  raw_data$V2<-as.character(raw_data$V2) 
  
  fac<-c("1","2","3","4","5","6","7","8","9")
  for (m in 1:length(fac)){
    for  (l in 1:length(raw_data[[2]])){
      if (raw_data[[2]][l]==m)
        raw_data[[2]][l]<-paste0("0",raw_data[[2]][l],sep='')
    }
  }
  
  tem <-raw_data[[1]][1] 
  
  for  (n in 1:length(raw_data[[2]])){
    if (raw_data[[2]][n]=="01") {
      tem<-substr(raw_data[[1]][n],start=1 ,stop = 8) 
      raw_data[[2]][n]<-paste0(tem,raw_data[[2]][n],sep='')
    }
    else {
      raw_data[[2]][n]<-paste0(tem,raw_data[[2]][n],sep='')
    }
  }
  raw_data<-select(raw_data,-1)
  

  # transfroming "&nbsp;" and "o"
  #column 12-15
  for(i in 12:15){
    for  (k in 1:length(raw_data[[i]])){
      if (raw_data[[i]][k]=="&nbsp;") {raw_data[[i]][k]="0"
      } else if (raw_data[[i]][k]=="o"){raw_data[[i]][k]="1"
      } else {raw_data[[i]][k]="0"
      }}
  }
  # transfroming "-" to zero in rainful data
  for  (k in 1:length(raw_data[[7]])){
    if (raw_data[[7]][k]=="-") {raw_data[[7]][k]="0"
    } 
  }
  
  # give table headers
  Header<-c("C_DATE","C_AVG_TEMP","C_MAX_TEMP","C_MIN_TEMP","SLP","H","C_RAINFULL","VV","V","VM","VG","C_RAIN","C_SNOW","C_STORM","C_FOG")
  colnames(raw_data) = Header
  
  # drive city and station from original data
  city<-as.character(city)
  city<-strsplit(city,",")
  city_name<-substr(city[[1]][1],start = 9 , stop = nchar(city[[1]][1]))
  city_obs <-strsplit(city[[1]][2],":")
  ob_station<-substr(city_obs[[1]][2],start = 2 , stop = nchar(city_obs[[1]][2]))
  
  # drive country from original data
  Country_name<-c()
  if ( city_name[1]=='Beijing') {Country_name<-c("China")
  }else if  (city_name[1]=="Shanghai") {Country_name[1]<-c("China")
  }else if  (city_name[1]=="Chengdu") {Country_name[1]<-c("China")
  }else if  (city_name[1]=="Guangzhou") {Country_name[1]<-c("China")
  }else if  (city_name[1]=="New Delhi") {Country_name[1]<-c("Inida")
  }else if  (city_name[1]=="Bombay") {Country_name[1]<-c("Inida")
  }else if  (city_name[1]=="Sydney") {Country_name[1]<-c("Austrila")
  }else if  (city_name[1]=="Bangkok") {Country_name[1]<-c("Thailand")
  }else if  (city_name[1]=="Taibei") {Country_name[1]<-c("Taiwan")
  }else if  (city_name[1]=="Manila") {Country_name[1]<-c("Philippine")
  }else if  (city_name[1]=="Ha Noi") {Country_name[1]<-c("Vietnam")
  }else if  (city_name[1]=="Ho Chi Minh") {Country_name[1]<-c("Vietnam")
  }
  
  # add new columns to the table
  raw_data$C_COUNTRY=Country_name[1]
  raw_data$C_CITY=city_name[1]
  # order columns
  raw_data_1<-select(raw_data,16:17)
  raw_data_2<-select(raw_data,1:4)
  raw_data_3<-select(raw_data,7)
  raw_data_4<-select(raw_data,12:15)
  raw_data<-cbind(raw_data_1,raw_data_2)
  raw_data<-cbind(raw_data,raw_data_3)
  raw_data<-cbind(raw_data,raw_data_4)
  #transforming format  
  raw_data$C_DATE<-as.Date(raw_data$C_DATE)
  raw_data$C_RAIN<-as.numeric(raw_data$C_RAIN)
  raw_data$C_SNOW<-as.numeric(raw_data$C_SNOW)
  raw_data$C_STORM<-as.numeric(raw_data$C_STORM)
  raw_data$C_FOG<-as.numeric(raw_data$C_FOG)
  # dealing with factor format
  return(raw_data)
}

Weather_Consolidation_data<-function(){
  target_files<-c("Shanghai.txt","Bombay.txt","Sydney.txt",
                  "Bangkok.txt","Beijing.txt","Chengdu.txt",
                  "Guangzhou.txt","New Delhi.txt","Taibei.txt",
                  "Manila.txt","Ha Noi.txt","Ho Chi Minh.txt")
  Raw.data<-Weather_Clean_data("./Weather_crawler_Main/Shanghai.txt")
  
  for (i in 2:length(target_files)){
    filepath <-paste0("./Weather_crawler_Main/",target_files[i])
    Raw.data<-rbind(Raw.data,Weather_Clean_data(filepath))
  }
  message("Start to Merge data ")
  
  write.csv(Raw.data,file = "./Weather_raw_dara_backup/Weather_Main_backup.csv",fileEncoding = "utf-8")
  return(Raw.data)
}

Weather_Alternative_data<-function(){
  message("Start to Alternative data to check raw data")
  raw_data<-read.table("./Weather_crawler_Alternative/Climate alternative data.txt",header = T,sep = ",",encoding = "UTF-8",stringsAsFactors = F)
  raw_data$CST<-as.Date(raw_data$CST)
  raw_data$Rain<-0
  raw_data$Snow<-0
  raw_data$Thunderstorm<-0
  raw_data$Fog<-0
  for (i in 1:length(raw_data[[1]])){
    temp<-strsplit(raw_data[[22]][i],split = "-")
    if (length(temp[[1]])>0){
      for (m in 1:length(temp[[1]])){
        if (temp[[1]][m]=="Rain") {raw_data[[25]][i]<-1}
        if (temp[[1]][m]=="Snow") {raw_data[[26]][i]<-1}
        if (temp[[1]][m]=="Thunderstorm") {raw_data[[27]][i]<-1}
        if (temp[[1]][m]=="Fog") {raw_data[[28]][i]<-1}
        
      }
      
    }
  }
  raw_data<-select(raw_data,c(1,2,3,4,24,25,26,27,28))
  names(raw_data)[5]<-"City"
  write.csv(raw_data,file = "./Weather_raw_dara_backup/Weather_alternative_backup.csv",fileEncoding = "utf-8")
  return(raw_data)
}

Weather_data_final_version<-function(){
  raw_data<-Weather_Consolidation_data()
  alternative_data<-Weather_Alternative_data()
  message("Start to generate final data")
  raw_data$MATCH<-paste(raw_data$C_CITY,raw_data$C_DATE,sep = "_")
  alternative_data$MATCH<-paste(alternative_data$City,alternative_data$CST,sep = "_")
  Merge_data<-merge(raw_data,alternative_data,by = "MATCH" , all.x = T , all.y = F)
  # 填补相关数据 寻找出仍然无法匹配的数据
  for (i in 1:length(Merge_data[[1]])){
    for (m in 1:3){
      if (!is.na(Merge_data[[13+m]][i])&Merge_data[[4+m]][i]=="-"){
        Merge_data[[4+m]][i]<-Merge_data[[13+m]][i]
      }
    }
    for (n in 1:4){
      if (Merge_data[[5]][i]=="-"&Merge_data[[6]][i]=="-"&Merge_data[[7]][i]=="-"){
        Merge_data[[8+m]][i]<-Merge_data[[17+m]][i]
        
      }
      
    }
  }
  Merge_data<-select(Merge_data,1:12)
  Merge_data[is.na(Merge_data)]<-0
  # 这里的算法写的非常不好，但是时间有些紧，就先将就用了
  for (l in 1:3){
    for (k in 1:length(Merge_data[[1]])){
      if (Merge_data[[4+l]][k]=="-"&Merge_data[[4+l]][k+1]=="-"&Merge_data[[4+l]][k+2]=="-"){
        temp <- (as.numeric(Merge_data[[4+l]][k-1])-as.numeric(Merge_data[[4+l]][k+3]))/4
        Merge_data[[4+l]][k]<-as.numeric(Merge_data[[4+l]][k-1])-temp
        Merge_data[[4+l]][k+1]<-as.numeric(Merge_data[[4+l]][k-1])-temp*2
        Merge_data[[4+l]][k+2]<-as.numeric(Merge_data[[4+l]][k-1])-temp*3
        k = k+3
        
      }
      if (Merge_data[[4+l]][k]=="-"&Merge_data[[4+l]][k+1]=="-"&!Merge_data[[4+l]][k+2]=="-"){
        temp <- (as.numeric(Merge_data[[4+l]][k-1])-as.numeric(Merge_data[[4+l]][k+2]))/3
        Merge_data[[4+l]][k]<-as.numeric(Merge_data[[4+l]][k-1])-temp
        Merge_data[[4+l]][k+1]<-as.numeric(Merge_data[[4+l]][k-1])-temp*2
        k = k+2
        
      }
      if (Merge_data[[4+l]][k]=="-"&!Merge_data[[4+l]][k+1]=="-"){
        Merge_data[[4+l]][k]<-(as.numeric(Merge_data[[4+l]][k-1])-as.numeric(Merge_data[[4+l]][k+2]))/2
        k = k+1
        
      }
      
      
    }
}
  Merge_data<-select(Merge_data,-1)
  for (i in 1:3){
    Merge_data[[3+i]]<-as.numeric(Merge_data[[3+i]])
    Merge_data[[3+i]]<-round(Merge_data[[3+i]],digits = 2)
  }
  write.csv(Merge_data,file = "./Weather_raw_dara_backup/Final_data_backup.csv",fileEncoding = "utf-8")
  return(Merge_data)
}
# ----------------------------------------------------
Fuel_loading_crude_oil_price<-function(){
  # loading raw data (need to change colnames as "PRICE")
  Brent <- read.csv("./Fuel_Brent_WTI_Raw_data/DCOILBRENTEU.csv",header = T , stringsAsFactors = F)
  names(Brent)<-c("DATE","PRICE")
  Brent$Name<-"BRENT"
  WTI<-read.csv("./Fuel_Brent_WTI_Raw_data/DCOILWTICO.csv",header = T , stringsAsFactors = F)
  names(WTI)<-c("DATE","PRICE")
  WTI$Name<-"WTI"
  # merge data and filter na value
  Merge_data<-rbind(Brent,WTI)
  Merge_data$DATE<-as.Date(Merge_data$DATE)
  for (i in 1:length(Merge_data[[1]])) {
    if (Merge_data[[2]][i]=="."){
      Merge_data[[2]][i]<-"0"}}
  Merge_data$PRICE<-as.numeric(Merge_data$PRICE)
  for (i in 1:length(Merge_data[[1]])) {
    if (Merge_data[[2]][i]=="0"){
      Merge_data[[2]][i]<-Merge_data[[2]][i-1]
    }
  }
  return(Merge_data)
}

Fuel_data_loading<-function(){
  Merge_data<-Fuel_loading_crude_oil_price()
  # generate working data for further analysis
  Raw_data<-read.xlsx("./Fuel_Brent_WTI_Raw_data/Match_data.xlsx")
  Raw_data$Date<-as.Date(Raw_data$Date)
  data_working<-merge(Merge_data,Raw_data,by.x = "DATE",by.y ="Date",all.x = T,all.y = F)
  data_working<-filter(data_working,!is.na(Country)) 
  return(data_working)
}

Fuel_generate_cofficient<-function(){
  data_working<-Fuel_data_loading()
  # generate adjusted coefficient 
  countrylist<-c("Austrilia","Thailand","India")
  country_original_list<-c("AU","TH","IN")
  crude_oillist<-c("BRENT","WTI")
  Type<-c("Petrol","Diesel")
  # initialization
  coef_table<-data.frame(matrix(NA,12,5) )
  names(coef_table)<-c("Country","Oil Name","Type","Adjusted coefficient(multiply crude oil)","T-value")
  Namelist<-c()
  Modellist<-c()
  x<-1
  y<-1
  # assign value
  for (i in 1:6) {
    if (i<=3){
      n=1
      Namelist[i]<-paste(countrylist[x],crude_oillist[n],sep ="_")
      assign(Namelist[i],filter(data_working,`Country`==country_original_list[x],`Name`==crude_oillist[n]))
      Modellist[i]<-paste("Model",countrylist[x],crude_oillist[n],"Petrol",sep ="_")
      Modellist[i+6]<-paste("Model",countrylist[x],crude_oillist[n],"Diesel",sep ="_")
      assign(Modellist[i],lm(Petrol~PRICE-1,data=get(Namelist[i])))
      assign(Modellist[i+6],lm(Diesel~PRICE-1,data =get(Namelist[i])))
      coef_table[[1]][i]<-countrylist[x]
      coef_table[[2]][i]<-crude_oillist[n]
      coef_table[[3]][i]<-"Petrol"
      coef_table[[4]][i]<-summary(get(Modellist[i]))$coefficients[1]
      coef_table[[5]][i]<-summary(get(Modellist[i]))$coefficients[3]
      coef_table[[1]][i+6]<-countrylist[x]
      coef_table[[2]][i+6]<-crude_oillist[n]
      coef_table[[3]][i+6]<-"Diesel"
      coef_table[[4]][i+6]<-summary(get(Modellist[i+6]))$coefficients[1]
      coef_table[[5]][i+6]<-summary(get(Modellist[i+6]))$coefficients[3]
      if (i<3){
        x=x+1
      }
    }else if (i>=4&i<=6){
      n=2
      Namelist[i]<-paste(countrylist[y],crude_oillist[n],sep ="_")
      assign(Namelist[i],filter(data_working,`Country`==country_original_list[y],`Name`==crude_oillist[n]))
      Modellist[i]<-paste("Model",countrylist[y],crude_oillist[n],"Petrol",sep ="_")
      Modellist[i+6]<-paste("Model",countrylist[y],crude_oillist[n],"Diesel",sep ="_")
      assign(Modellist[i],lm(Petrol~PRICE-1,data=get(Namelist[i])))
      assign(Modellist[i+6],lm(Diesel~PRICE-1,data =get(Namelist[i])))
      coef_table[[1]][i]<-countrylist[y]
      coef_table[[2]][i]<-crude_oillist[n]
      coef_table[[3]][i]<-"Petrol"
      coef_table[[4]][i]<-summary(get(Modellist[i]))$coefficients[1]
      coef_table[[5]][i]<-summary(get(Modellist[i]))$coefficients[3]
      coef_table[[1]][i+6]<-countrylist[y]
      coef_table[[2]][i+6]<-crude_oillist[n]
      coef_table[[3]][i+6]<-"Diesel"
      coef_table[[4]][i+6]<-summary(get(Modellist[i+6]))$coefficients[1]
      coef_table[[5]][i+6]<-summary(get(Modellist[i+6]))$coefficients[3]
      if (i<6){
        y=y+1
      }
    }
  }
  write.csv(coef_table,file = "./Fuel_Brent_WTI_cofficient/Cofficient_table_backup.csv")
  return(coef_table)
}

Fuel_data_AI_Crude<-function(){
  Merge_data<-Fuel_loading_crude_oil_price()
  coef_table<-Fuel_generate_cofficient()
  test<-merge(Merge_data,coef_table,by.x = "Name",by.y = "Oil Name",all.x = T,all.y = F)
  test$Price<-round(test$PRICE*test$`Adjusted coefficient(multiply crude oil)`,digits = 3)
  test<-select(test,c(2,4,1,5,8))
  test<-filter(test,`DATE`>"2007-12-31")
  write.csv(test,file = "./Fuel_Brent_WTI_Raw_data/Final_data_backup.csv")
  return(test)
}

Fuel_data_china<-function(){
  raw_data<-read.table("./Fuel_China/China oil price.txt",header = F,sep = "\t",encoding = "UTF-8",stringsAsFactors = F,skip = 1)
  names(raw_data)<-c("Date","City","90","92","95","0")
  for (i in 1:length(raw_data[[1]])){
    temp1<-substr(raw_data[[1]][i],1,4)
    temp2<-substr(raw_data[[1]][i],5,6)
    temp3<-substr(raw_data[[1]][i],7,8)
    raw_data[[1]][i]<-paste(temp1,temp2,temp3,sep = "-")
  }
  raw_data$Date<-as.Date(raw_data$Date)
  raw_data<-arrange(raw_data,`City`,`Date`)
  write.csv(raw_data,file = "./Fuel_China/Fuel_china_backup.csv")
  raw_data<-filter(raw_data,`City`=="上海")
  raw_data<-select(raw_data,c(1,2,4))
  raw_data<-na.omit(raw_data)
  return(raw_data)
}
  
Fuel_data_thailand<-function(){
  Raw_data<-read.csv("./Fuel_Thailand/Thailand oil price.txt",header = T,sep = "," ,stringsAsFactors = F)
  Raw_data$Time<-as.Date(Raw_data$Time,origin = "1899-12-30")
  # here are some codes for errors , please transform the data to csv format
  # Raw_data<-read.csv("Thailand oil price.csv",header = T,stringsAsFactors = F)
  # Raw_data$Time<-as.Date(Raw_data$Time,origin = "1899-12-30")
  # Wrong_data<-filter(Raw_data,`Time`=="2012-11-01")
  # Raw_data<-filter(Raw_data,`Time`!="2012-11-01")
  # Wrong_data[is.na(Wrong_data)]<-"-"
  # for (i in 29:63) {
  #   if (i!=63){
  #     Wrong_data[[9]][i-1]<-Wrong_data[[2]][i]
  #     Wrong_data[[10]][i-1]<-Wrong_data[[3]][i]
  #     for (m in 4:12){
  #       Wrong_data[[m-2]][i]<-Wrong_data[[m]][i]
  #     }
  #     
  #   }else {
  #     Wrong_data[[9]][i-1]<-Wrong_data[[2]][i]
  #     Wrong_data[[10]][i-1]<-Wrong_data[[3]][i]
  #     for (m in 4:13){
  #       Wrong_data[[m-3]][i]<-Wrong_data[[m]][i]}
  #   }
  # }
  # Raw_data<-rbind(Raw_data,Wrong_data)
  # Raw_data<-select(Raw_data,-c(11:13))
  # Raw_data<-arrange(Raw_data,Time)
  for (i in 1:length(Raw_data[[1]])){
    if (Raw_data[[7]][i]=="-"){
      Raw_data[[7]][i]<-NA
    }
  }
  Raw_data<-select(Raw_data,c(1,7))
  Raw_data<-na.omit(Raw_data)
  Raw_data<-filter(Raw_data,`Gas_THB`!="0")
  Raw_data$Gas_THB<-as.numeric(Raw_data$Gas_THB)
  Raw_data<-group_by(Raw_data,Time)%>%summarise(gas_avg=mean(Gas_THB))
  write.csv(Raw_data,file = "./Fuel_Thailand/DATA_backup.csv")
  return(Raw_data)
}

Fuel_data_final_version<-function(){
  China<-Fuel_data_china()
  Thianland<-Fuel_data_thailand()
  AI<-Fuel_data_AI_Crude()
  Austrilia<-filter(AI,`Country`=="Austrilia"&`Name`=="WTI"&`Type`=="Diesel")
  India<-filter(AI,`Country`=="India"&`Name`=="WTI"&`Type`=="Petrol")
  Data_China<-select(China,c(1,3))
  Data_China$Country<-"China"
  Data_Thailand<-Thianland
  Data_Thailand$Country<-"Thailand"
  Data_Austrilia<-select(Austrilia,c(1,5,2))
  Data_India<-select(India,c(1,5,2))
  names(Data_China)<-c("Date","Price","Country")
  names(Data_Thailand)<-c("Date","Price","Country")
  names(Data_Austrilia)<-c("Date","Price","Country")
  names(Data_India)<-c("Date","Price","Country")
  Final_data<-rbind(Data_China,Data_Thailand)
  Final_data<-rbind(Final_data,Data_Austrilia)
  Final_data<-rbind(Final_data,Data_India)
  Final_data<-filter(Final_data,`Date`>="2013-01-01")
  write.csv(Final_data,file = "./Fuel_price_backup/Fuel_price_backup.csv")
  return(Final_data)
}
# ----------------------------------------------------
Stock_Google<-function() {
  Stock_Readtxt<-function(txtpath){
    raw_data<-read.table(txtpath,header = T,sep = "\t",fileEncoding = "utf-8",stringsAsFactors = F)
    return(raw_data)
  }
  # 生成文件名
  Exchange_name <- c("Austrilia.txt","China-Shanghai.txt","China-Shenzhen.txt",
                     "India.txt","New zealand.txt","Taiwan.txt","Thailand.txt")
  for (m in 1:length(Exchange_name)){
    Exchange_name[m]<-paste0("./Stock_Price_Google/",Exchange_name[m])
  }
  # 读写文件
  for (i in 1:length(Exchange_name)){
    if (i == 1) {
      final_data<-Stock_Readtxt(Exchange_name[i])}
    if (i!=1){
      final_data<-rbind(final_data,raw_data)
    }
    raw_data<-Stock_Readtxt(Exchange_name[i])
  }
  return(final_data)
}

Stock_Yahoo<-function(){
  Austrilia<-read.csv("./Stock_Price_Yahoo/ASX 200.csv",stringsAsFactors = FALSE)
  Austrilia$Date<-as.Date(Austrilia$Date) 
  Austrilia$Country="Australia"
  Austrilia$Code="ASX 200"
  Austrilia<-select(Austrilia,c(8,9,1,2,3,4,5))
  
  India<-read.csv("./Stock_Price_Yahoo/BSE SENSEX.csv",stringsAsFactors = FALSE)
  India$Date<-as.Date(India$Date) 
  India$Country="India"
  India$Code="BSE SENSEX"
  India<-select(India,c(8,9,1,2,3,4,5))
  
  China_sse<-read.csv("./Stock_Price_Yahoo/SSE Composite Index.csv",stringsAsFactors = FALSE)
  China_sse$Date<-China_sse$Date<-as.Date(China_sse$Date) 
  China_sse$Country="China"
  China_sse$Code="SSE Composite Index"
  China_sse<-select(China_sse,c(6,7,1,5,3,4,2))
  
  China_szse<-read.csv("./Stock_Price_Yahoo/SZSE COMP SUB IND.csv",stringsAsFactors = FALSE)
  China_szse$Date<-China_szse$Date<-as.Date(China_szse$Date) 
  China_szse$Country="China"
  China_szse$Code="SZSE COMP SUB IND"
  China_szse<-select(China_szse,c(6,7,1,5,3,4,2))
  
  Final_data<-rbind(Austrilia,India)
  Final_data<-rbind(Final_data,China_sse)
  Final_data<-rbind(Final_data,China_szse)
  Final_data<-filter(Final_data,`Date`>"2007-12-31")
  return(Final_data)
}
# ----------------------------------------------------
Holiday_data<-function(){
  raw_name<-c("China","India","Australia","Thailand","Taiwan","Philippines","Indonesia")
  
  
  for (i in 1:7) {
    raw_data<-read.xlsx("./Holiday_raw_data/holiday data.xlsx",sheet = i)
    raw_data$Date<-as.Date(raw_data$Date,origin="1899-12-30")
    raw_data<-select(raw_data,1:4)
    raw_data$Country<-raw_name[[i]][1]
    if (i==1){
      raw_data_new<-raw_data
    }
    else {
      raw_data_new<-rbind(raw_data_new,raw_data)
    }
    
  }
  write.csv(raw_data_new,file = "./Holiday_raw_data/Holiday_Raw_data_Cleanned.csv")
  return(raw_data_new)
}

Holiday_data_cleaning<-function(Country_name,Developer = FALSE,Date_option = FALSE,Date_input){
  #Country_name<-"China"
  # Year<-2017
  if (Date_option){begin_data<-Date_input}else{
    begin_data<-"2010-01-04"
  }
  Initialization<-function(){
    raw_data<-Holiday_data()
    name_list<-read.xlsx("./Holiday_raw_data/Holiday_name_list.xlsx")
    raw_data$MATCH<-paste(raw_data$Country,raw_data$Holiday,sep = "_")
    name_list$MATCH<-paste(name_list$Country,name_list$Holiday,sep = "_")
    name_list<-distinct(name_list)
    raw_data<-merge(raw_data,name_list,by = "MATCH" , all.x = T , all.y = F)
    return(raw_data)
  }
  raw_data<-Initialization()
  # write dismatch data
  if (Developer){
    check<-filter(raw_data,is.na(Rename))
    write.csv(check,file = "./Holiday_Data_back_up/Holiday_dismatch.csv")
  }
  # standardlized data
  data_filter_bycountry<-function(raw_data,name_list,Country_name){
    raw_data<-filter(raw_data,`Country.x`==Country_name)
    raw_data<-arrange(raw_data,Date)
    name_list<-select(raw_data,c(3,9))%>%distinct()
    raw_data$count<-0
    len<-length(names(raw_data))
    for (i in 1:len){
      raw_data[[i]]<-trimws(raw_data[[i]],"l")
      raw_data[[i]]<-trimws(raw_data[[i]],"r")
    }
    name_list[[1]]<-trimws(name_list[[1]],"l")
    name_list[[1]]<-trimws(name_list[[1]],"r")
    raw_data<-distinct(raw_data)
    name_list<-distinct(name_list)
    raw_data<-na.omit(raw_data)
    name_list<-na.omit(name_list)
    name_list<-select(name_list,-1) %>% distinct()
    for (i in 2:length(raw_data[[1]])){
      if (raw_data[[2]][i]==(as.Date(raw_data[[2]][i-1])+1)&raw_data[[9]][i]==raw_data[[9]][i-1]){
        raw_data[[10]][i]<-as.numeric(raw_data[[10]][i-1])+1
      }
    }
    
    
    raw_data$Final_name<-"-"
    for (m in 1:length(raw_data[[1]])){
      if (raw_data[[10]][m]==0){
        raw_data[[11]][m]<-raw_data[[9]][m]
      }else{
        raw_data[[11]][m]<-paste(raw_data[[9]][m],raw_data[[10]][m],sep = "_")}
    }
    New_date<-seq.Date(as.Date("2010-01-01"),as.Date("2020-01-01"),"day")
    Newdata<-as.data.frame(New_date)
    New_names<-c("Date")
    name_list<-unique(raw_data[[11]])
    for (i in 1:length(name_list)){
      Newdata[[1+i]]<-0
      New_names[i+1]<-name_list[i]
    }
    names(Newdata)<-New_names
    Newdata<-merge(Newdata,raw_data,by = "Date",all.x = T,all.y =T )
    Newdata[is.na(Newdata)]<-"0"
    
    
    
    for (m in 1:length(Newdata[[1]])){
      for (i in 1:length(New_names)){
        if (New_names[i] == Newdata[[length(New_names)+10]][m]){
          Newdata[[i]][m]<-1
        }
      }
      
    }
    Newdata<-select(Newdata,1:length(New_names))
    
    Newdata<-Newdata%>%tidyr::gather(Hol,Values,-Date)  %>%
      group_by(`Date`,`Hol`)%>%summarise(Values=sum(as.numeric(Values)))%>% 
      tidyr::spread(Hol,Values)
    Newdata$Warning<-0
    
    for (m in 2:length(New_names)){
      Newdata[[m]]<-as.numeric(Newdata[[m]])
      Newdata[[length(New_names)+1]]<-Newdata[[length(New_names)+1]]+Newdata[[m]]
    }
    Newdata$Warning<-as.character(Newdata$Warning)
    for (i in 1:length(Newdata[[1]])){
      if (Newdata[[1+length(New_names)]][i]=="2"){
        Newdata[[1+length(New_names)]][i]<-"Holiday overlapped!"
      }else{
        Newdata[[1+length(New_names)]][i]<-""
      }
    }
    return(Newdata)
  }
  # data special for Australia
  data_filter_AU<-function(raw_data,name_list){
    raw_data<-filter(raw_data,`Country.x`=="Australia")
    raw_data<-arrange(raw_data,Date)
    name_list<-select(raw_data,c(3,9))%>%distinct()
    raw_data$count<-0
    len<-length(names(raw_data))
    for (i in 1:len){
      raw_data[[i]]<-trimws(raw_data[[i]],"l")
      raw_data[[i]]<-trimws(raw_data[[i]],"r")
    }
    name_list[[1]]<-trimws(name_list[[1]],"l")
    name_list[[1]]<-trimws(name_list[[1]],"r")
    raw_data<-distinct(raw_data)
    name_list<-distinct(name_list)
    raw_data<-na.omit(raw_data)
    name_list<-na.omit(name_list)
    name_list<-select(name_list,-1) %>% distinct()
    for (i in 2:length(raw_data[[1]])){
      if (raw_data[[2]][i]==(as.Date(raw_data[[2]][i-1])+1)&raw_data[[9]][i]==raw_data[[9]][i-1]){
        raw_data[[10]][i]<-as.numeric(raw_data[[10]][i-1])+1
      }
    }
    raw_data$Final_name<-"-"
    for (m in 1:length(raw_data[[1]])){
      if (raw_data[[10]][m]==0){
        raw_data[[11]][m]<-raw_data[[9]][m]
      }else{
        raw_data[[11]][m]<-paste(raw_data[[9]][m],raw_data[[10]][m],sep = "_")}
    }
    New_date<-seq.Date(as.Date("2010-01-01"),as.Date("2020-01-01"),"day")
    Newdata<-as.data.frame(New_date)
    New_names<-c("Date")
    for (i in 1:length(name_list[[1]])){
      Newdata[[1+i]]<-0
      New_names[i+1]<-name_list[[1]][i]
    }
    names(Newdata)<-New_names
    Newdata<-merge(Newdata,raw_data,by = "Date",all.x = T,all.y =T )
    Newdata[is.na(Newdata)]<-"0"
    for (m in 1:length(Newdata[[1]])){
      x<-0
      if (Newdata[[length(New_names)+4]][m]!="0"&Newdata[[length(New_names)+4]][m]!="National"){
        a<-strsplit(Newdata[[length(New_names)+4]][m],split = ",")
        for (t in 1:length(a[[1]])){
          if (a[[1]][t]=="QLD"|a[[1]][t]=="NSW"|a[[1]][t]=="VIC"|a[[1]][t]=="ACT"){
          x<-1 }
        }
        if (x!=1){
          Newdata[[length(New_names)+8]][m]<-"0"
        }
      }
    }
  
    for (m in 1:length(Newdata[[1]])){
      for (i in 1:length(New_names)){
        if (New_names[i] == Newdata[[length(New_names)+8]][m]){
          Newdata[[i]][m]<-1
        }
      }
      
    }
    Newdata<-select(Newdata,1:length(New_names))
    Newdata<-Newdata%>%tidyr::gather(Hol,Values,-Date)  %>%
      group_by(`Date`,`Hol`)%>%summarise(Values=sum(as.numeric(Values)))%>% 
      tidyr::spread(Hol,Values)
    Newdata$Warning<-0
    for (m in 2:length(New_names)){
      Newdata[[m]]<-as.numeric(Newdata[[m]])
      Newdata[[length(New_names)+1]]<-Newdata[[length(New_names)+1]]+Newdata[[m]]
    }
    Newdata$Warning<-as.character(Newdata$Warning)
    for (i in 1:length(Newdata[[1]])){
      if (Newdata[[1+length(New_names)]][i]=="2"){
        Newdata[[1+length(New_names)]][i]<-"Holiday overlapped!"
      }else{
        Newdata[[1+length(New_names)]][i]<-""
      }
    }
    return(Newdata)
  }
  # data special for China
  data_filter_CN<-function(raw_data,name_list){
    raw_data<-Initialization()
    raw_data<-filter(raw_data,`Country.x`=="China")
    raw_data<-arrange(raw_data,Date)
    name_list<-select(raw_data,c(3,9))%>%distinct()
    raw_data$count<-0
    len<-length(names(raw_data))
    for (i in 1:len){
      raw_data[[i]]<-trimws(raw_data[[i]],"l")
      raw_data[[i]]<-trimws(raw_data[[i]],"r")
    }
    name_list[[1]]<-trimws(name_list[[1]],"l")
    name_list[[1]]<-trimws(name_list[[1]],"r")
    raw_data<-distinct(raw_data)
    name_list<-distinct(name_list)
    raw_data<-na.omit(raw_data)
    name_list<-na.omit(name_list)
    name_list<-select(name_list,-1) %>% distinct()
    raw_data<-arrange(raw_data,Holiday.x,Date)
    for (i in 2:length(raw_data[[1]])){
      if (raw_data[[2]][i]==(as.Date(raw_data[[2]][i-1])+1)&raw_data[[9]][i]==raw_data[[9]][i-1]){
        raw_data[[10]][i]<-as.numeric(raw_data[[10]][i-1])+1
      }
    }
    
    
    raw_data$Final_name<-"-"
    for (m in 1:length(raw_data[[1]])){
      if (raw_data[[10]][m]==0){
        raw_data[[11]][m]<-raw_data[[9]][m]
      }else{
        raw_data[[11]][m]<-paste0(raw_data[[9]][m],"_P",raw_data[[10]][m])}
    }
    New_date<-seq.Date(as.Date("2010-01-01"),as.Date("2020-01-01"),"day")
    Newdata<-as.data.frame(New_date)
    New_names<-c("Date")
    name_list<-unique(raw_data[[11]])
    compulsary_name<-c()
    for (i in 10:1){
      Name_column<-paste0("H_CNY_M",i)
      compulsary_name<-c(compulsary_name,Name_column)
    }
    compulsary_name<-c(compulsary_name,"H_CNY")
    for (i in 1:10){
      Name_column<-paste0("H_CNY_P",i)
      compulsary_name<-c(compulsary_name,Name_column)
    }
    for (i in 5:1){
      Name_column<-paste0("H_NY_M",i)
      compulsary_name<-c(compulsary_name,Name_column)
    }
    compulsary_name<-c(compulsary_name,"H_NY")
    for (i in 1:5){
      Name_column<-paste0("H_NY_P",i)
      compulsary_name<-c(compulsary_name,Name_column)
    }
    for (i in 7:1){
      Name_column<-paste0("H_ND_M",i)
      compulsary_name<-c(compulsary_name,Name_column)
    }
    compulsary_name<-c(compulsary_name,"H_ND")
    for (i in 1:7){
      Name_column<-paste0("H_ND_P",i)
      compulsary_name<-c(compulsary_name,Name_column)
    }
    namelist_todrop<-c()
    for (t in 1:length(name_list)){
      for (i in 1:length(compulsary_name)){
        if (name_list[t]==compulsary_name[i]){
          namelist_todrop<-c(namelist_todrop,t)
        }
      }
    }
    a<-seq.int(from = 1,to = length(name_list))
    name_list<-name_list[-match(namelist_todrop,a)]  
    name_list<-c(compulsary_name,name_list)
    
    for (i in 1:length(name_list)){
      Newdata[[1+i]]<-0
      New_names[i+1]<-name_list[i]
    }
    names(Newdata)<-New_names
    Newdata<-merge(Newdata,raw_data,by = "Date",all.x = T,all.y =T )
    Newdata[is.na(Newdata)]<-"0"


    for (m in 1:length(Newdata[[1]])){
      for (i in 1:length(New_names)){
        if (New_names[i] == Newdata[[length(New_names)+10]][m]){
          Newdata[[i]][m]<-1
        }
      }
    }
    
    
    Newdata<-select(Newdata,1:length(New_names))
    
    
    
    Newdata<-Newdata%>%tidyr::gather(Hol,Values,-Date)  %>%
      group_by(`Date`,`Hol`)%>%summarise(Values=sum(as.numeric(Values)))%>% 
      tidyr::spread(Hol,Values)
    
    name_need_arrange<-names(Newdata)
    name_range<-c()
    for (i in 1:length(New_names)){
      for (m in 1:length(name_need_arrange)){
        if (New_names[i]==name_need_arrange[m]){
          name_range<-c(name_range,m)
        }
      }
      
    }
    Newdata<-select(Newdata,name_range)  
    for(i in 1:length(New_names)){
      if (New_names[i]=="H_CNY"){
        CNY<-i
      }
      if (New_names[i]=="H_NY"){
        NY<-i
      }
      if (New_names[i]=="H_ND"){
        ND<-i
      }
      
    }
    for (m in 11:(length(Newdata[[1]])-11)){
      if (Newdata[[CNY]][m]==1){
        for (t in 1:10){
          Newdata[[CNY+t]][m+t]<-1
          Newdata[[CNY-t]][m-t]<-1
          
        }
      }
      if (Newdata[[NY]][m]==1){
        for (t in 1:5){
          Newdata[[NY+t]][m+t]<-1
          Newdata[[NY-t]][m-t]<-1
          
        }
      }
      if (Newdata[[ND]][m]==1){
        for (t in 1:7){
          Newdata[[ND+t]][m+t]<-1
          Newdata[[ND-t]][m-t]<-1
          
        }
      }
      
    }
    
    
     Newdata$Warning<-0
    
    for (m in 2:length(New_names)){
      Newdata[[m]]<-as.numeric(Newdata[[m]])
      Newdata[[length(New_names)+1]]<-Newdata[[length(New_names)+1]]+Newdata[[m]]
    }
    Newdata$Warning<-as.character(Newdata$Warning)
    for (i in 1:length(Newdata[[1]])){
      if (Newdata[[1+length(New_names)]][i]=="2"){
        Newdata[[1+length(New_names)]][i]<-"Holiday overlapped!"
      }else{
        Newdata[[1+length(New_names)]][i]<-""
      }
    }
    return(Newdata)
  }
  # data China weekly 
  data_filter_CN_week<-function(raw_data,name_list,begin_data){
    raw_data<-Initialization()
    raw_data<-filter(raw_data,`Country.x`=="China")
    raw_data<-arrange(raw_data,Date)
    name_list<-select(raw_data,c(3,9))%>%distinct()
    raw_data$count<-0
    len<-length(names(raw_data))
    for (i in 1:len){
      raw_data[[i]]<-trimws(raw_data[[i]],"l")
      raw_data[[i]]<-trimws(raw_data[[i]],"r")
    }
    name_list[[1]]<-trimws(name_list[[1]],"l")
    name_list[[1]]<-trimws(name_list[[1]],"r")
    raw_data<-distinct(raw_data)
    name_list<-distinct(name_list)
    raw_data<-na.omit(raw_data)
    name_list<-na.omit(name_list)
    name_list<-select(name_list,-1) %>% distinct()
    raw_data<-arrange(raw_data,Holiday.x,Date)
    for (i in 2:length(raw_data[[1]])){
      if (raw_data[[2]][i]==(as.Date(raw_data[[2]][i-1])+1)&raw_data[[9]][i]==raw_data[[9]][i-1]){
        raw_data[[10]][i]<-as.numeric(raw_data[[10]][i-1])+1
      }
    }
    
    raw_data$Final_name<-"-"
    for (m in 1:length(raw_data[[1]])){
      if (raw_data[[10]][m]==0){
        raw_data[[11]][m]<-raw_data[[9]][m]
      }else{
        raw_data[[11]][m]<-paste0(raw_data[[9]][m],"_P",raw_data[[10]][m])}
    }
    New_date<-seq.Date(as.Date(begin_data),as.Date("2020-01-01"),"week")
    Newdata<-as.data.frame(New_date)
    New_names<-c("Date")
    New_list<-c()
    for (i in 1:length(name_list[[1]])){
      Temp<-name_list[[1]][i]
      Temp_PRE<-paste(name_list[[1]][i],"PRE",sep = "_")
      Temp_POST<-paste(name_list[[1]][i],"POST",sep = "_")
      New_list<-c(New_list,Temp_PRE)
      New_list<-c(New_list,Temp)
      New_list<-c(New_list,Temp_POST)
      New_names<-c(New_names,Temp_PRE)
      New_names<-c(New_names,Temp)
      New_names<-c(New_names,Temp_POST)
    }
    for (i in 1:length(New_list)){
      Newdata[[1+i]]<-0
      New_names[i+1]<-New_list[i]
    }
    names(Newdata)<-New_names
    sequence<-c()
    for (i in 1:length(New_names)){
      for (t in 1:length(name_list[[1]])){
        if (New_names[i]==name_list[[1]][t]){
          sequence<-c(sequence,i)
        }
      }
    }
    raw_data$Date<-as.Date(raw_data$Date)

    for (t in 1:length(raw_data[[1]])){
      for (i in 1:length(Newdata[[1]])){
        cal<-raw_data[[2]][t]-Newdata[[1]][i]
        temp_col<-raw_data[[9]][t]
        if (cal>=0&cal<=6){
            for (l in 1:length(name_list[[1]])){
            if (name_list[[1]][l]==temp_col) {
              num<-sequence[l]
              Newdata[[num]][i]<-1
            }
          }
          }
        }
      }
    
    for (i in 1:length(Newdata[[1]])){
      for (t in 1:length(name_list[[1]])){
        if (Newdata[[sequence[t]]][i]==1){
          Newdata[[sequence[t]+1]][i+1]<-1
          Newdata[[sequence[t]-1]][i-1]<-1
          
        }
      }
    }
  
    return(Newdata)
  }
  
  
  if (Developer){
    Country_name_list<-c("India","Indonesia","China",
                        "Philippines","Taiwan","Thailand")
    for (i in 1:length(Country_name_list)){
      Country_name<-Country_name_list[i]
      Data_for_write<-data_filter_bycountry(raw_data,name_list,Country_name)
      Filename<-paste0("./Holiday_Data_back_up/",Country_name,".csv")
      write.csv(Data_for_write,file = Filename )
    }
    Data_for_write<-data_filter_AU(raw_data,name_list)
    write.csv(Data_for_write,file = "./Holiday_Data_back_up/Australia.csv" )
    Data_for_write<-data_filter_CN(raw_data,name_list)
    write.csv(Data_for_write,file = "./Holiday_Data_back_up/China_Modeling.csv" )
    Data_for_write<-data_filter_CN_week(raw_data,name_list,begin_data)
    write.csv(Data_for_write,file = "./Holiday_week_back_up/China_Modeling_week.csv" )
    
    Newdata<-""
    }else{
    Newdata<-data_filter_bycountry(raw_data,name_list,Country_name)
  } 
  
  return(Newdata)
    }
  