library("xml2")

snap_date <- format(Sys.time(), "%Y-%m-%d")

download_xml("http://dir.xiph.org/yp.xml", file = paste0("yp", "_", snap_date, ".xml"))
yp <- xml2::read_xml(paste0("yp", "_", snap_date, ".xml"))
yp_ls <- xml2::as_list(yp)

df <- data.frame()
for (d in 1:length(yp_ls[[1]])) {
  
  server_name <- unlist(yp_ls[[1]][[d]][["server_name"]])
  server_type <- unlist(yp_ls[[1]][[d]][["server_type"]])
  bitrate <- as.numeric(unlist(yp_ls[[1]][[d]][["bitrate"]]))
  listen_url <- unlist(yp_ls[[1]][[d]][["listen_url"]])
  genre <- unlist(yp_ls[[1]][[d]][["genre"]])
  
  if (!is.null(server_name) & !is.null(server_type) & !is.null(bitrate) & !is.null(listen_url) & !is.null(genre)) {
    if (bitrate == 0 || bitrate >= 128) {
      df.l <- data.frame(Artist = server_name,
                         Encoding = server_type,
                         Bitrate = bitrate,
                         URL = listen_url,
                         Genre = genre)
      df <- rbind(df, df.l)
    }
  }
}

df$Artist <- gsub('[",]', " ", df$Artist)
df$Artist <- gsub("-", "", df$Artist)
df$Genre <- gsub('[",]', " ", df$Genre)

stations <- paste0("#EXTM3U")
for (r in 1:nrow(df)) {
  stations[r+1] <- paste0(
    #"#EXTINF:0,", df$Artist[r+1], " :: ",  df$Encoding[r+1], " (", df$Bitrate[r+1], ") ",  "\n",
    #"#EXTINF:0,", df$Artist[r+1], " - ", df$Encoding[r+1], " (", df$Bitrate[r+1], ") ", "\n",
    "#EXTINF:0,", df$Artist[r+1], " :: ",  df$Encoding[r+1], " (", df$Bitrate[r+1], ") ", " - ", df$Genre[r+1], "\n",
    df$URL[r+1])
}
writeLines(stations, paste0("xiph_", snap_date, ".m3u"))
