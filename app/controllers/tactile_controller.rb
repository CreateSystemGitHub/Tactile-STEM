#
# グローバル変数
#   $aaa
# インスタンス変数（クラス内）
#   @bbb
# クラス変数（そのクラスの全てのインスタンスで共有される変数）
#   @@ccc
# ローカル変数（メソッド内やブロック内のみ）
#   ddd
#
# def はメソッド定義

class TactileController < ApplicationController

  @@book_title = []
  @@book_imgfile = []
  @@book_folder = []
  @@book_content = []
  @@book_id = 0

  $now_page_id = 4
  
  
  #################################################
  #  unzip book data to WORK folder
  # ex) unzippagedata(zipname, pagename)
  #   zipname: 'HH.zip'
  #             HH/HH0/HH-1/*.jpg, *.mpg, *.txt ---
  #             HH/Contents.txt
  #   pagename: 'HH-10' or nil means 'Content.txt'
  #################################################
  def unzippagedata(zipname, pagename)
    require 'zip'
    require 'fileutils'
    src = 'app/assets/images/' 
    dest = 'app/assets/images/WORK'
    FileUtils.rm_rf(dest)     #delete folder and files
    FileUtils.mkdir_p(dest)   #make folder
    Zip::File.open(src + zipname + '.zip') do |zip|  #open zipfile
      zip.each do |entry|
        files = entry.name.split("/",4)
        if files.length==2 then
          if files[1].casecmp?("contents.txt") then
            #copy contents.txt
            #srcf = entry.name
            #dstf = dest + "/" +files[1]
            #p "copy " + srcf + " to " + dstf
            #zip.extract(entry, dstf) { true }  #true=上書き
            dir = File.join(dest, File.dirname(entry.name))
            FileUtils.mkdir_p(dir)
            zip.extract(entry, dest +"/"+ entry.name) { true }  #true=上書き
            if pagename==nil then return end
          end
        end
        if files.length==4 && pagename!=nil then
          if pagename.casecmp?(files[2]) && files[3].length>0 then
            dir = File.join(dest, File.dirname(entry.name))
            FileUtils.mkdir_p(dir)
            zip.extract(entry, dest +"/"+ entry.name) { true }  #true=上書き
          end
        end
      end
    end
  end
  def copyContentsFileToWorkForDebug(folder)
    require 'fileutils'
    src = "app/assets/images/" + folder + "/Contents.txt"
    dst = "app/assets/images/WORK/" + folder 
    FileUtils.mkdir_p(dst)   #make folder
    FileUtils.cp(src, dst)
  end
  def copyDataToWorkForDebug(folder, pagename)
    require 'fileutils'
    src = "app/assets/images/" + folder + "/" + folder + "0/" + pagename
    dst = "app/assets/images/WORK"
    dst2 = dst + "/" + folder + "/" + folder + "0/" + pagename
    FileUtils.rm_rf(dst)     #delete folder and files
    FileUtils.mkdir_p(dst2)   #make folder
    FileUtils.cp_r(src, dst2)
  end

  #####################################
  def readmokujifile(folder)
    require "csv"
    if asset_exists?(folder + ".zip")then
      p "MOKUJI:Unzip:#{folder}.zip"
      unzippagedata(folder, nil)
    else
      p "MOKUJI:Copy:#{folder}"
      copyContentsFileToWorkForDebug(folder)
    end
    src = "app/assets/images/WORK/"+ folder + "/Contents.txt"
    @pagenos = []
    @filenames = []
    @contents = []
    CSV.foreach(src, encoding:"UTF-8", col_sep: ":" ) do |line1|
      aa = line1[0]
      bb = line1[1]
      cc = line1[2]
      if aa.blank? or bb.blank? or cc.blank?
      else
        @pagenos << aa.strip
        @filenames << bb.strip
        @contents << cc.strip
      end
    end
    @max_page = @pagenos.length - 1
  end

  #####################################
  # index
  #####################################
  def index
    p "**** INDEX START *****"
    #cashfile()
    require "csv"
    src="app/assets/images/BOOKS/books.csv"
    @book_title = []
    @book_imgfile = []
    @book_folder = []
    @book_content = []
    CSV.foreach(src, headers: true) do |line|
#      @book_id << line["id"]
      @book_title << line["title"]
      @book_imgfile << "/assets/BOOKS/"+line["imgfile"]
      @book_folder << line["folder"]
      @book_content << line["content"]
    end
    @@book_title = @book_title
    @@book_imgfile = @book_imgfile
    @@book_folder = @book_folder
    @@book_content = @book_content
    @max_book_size = @book_folder.length - 1
    p "**** INDEX END *****"
  end


  #####################################
  # 目次
  #####################################
  def mokuji
    p "**** MOKUJI START *****"
    if @@book_folder==nil then index() end
    if @@book_folder.length==0 then index() end
    @book_id = params[:book_id]
    if @book_id == nil then
      @book_id = 0
      p "XXXXXXXXXXXX" 
    end
    @folder = @@book_folder[@book_id.to_i]
    @title = @@book_title[@book_id.to_i]
    @page_id = params[:pid]
    if @page_id == nil then @page_id = $now_page_id end  #current page id  
    p "Mokuji:book_id=#{@book_id},folder=#{@folder}, title=#{@title}"

    #read mokuji content.txt in book
    readmokujifile(@folder)
    @subpage = 0
    @@book_id = @book_id
    p "Mokuji:page_id=#{@page_id}, sub_page=#{@subpage}"
    p "**** MOKUJI END *****"
  end
 
  ###############################################
  # 本文
  # tactile_show_path(@book_id,@next_id,"0","0")
  #:book/:pid/:spaid/:fn
  ###############################################
  def show
    p "**** SHOW START *****"
    @max_imagemap = -1;
    if @@book_folder==nil then index() end
    if @@book_folder.length==0 then index() end
    @book_id = params[:book_id]
    if @book_id == nil then @book_id = 0 end
    @folder = @@book_folder[@book_id.to_i]
    @title = @@book_title[@book_id.to_i]
    p "show folder=#{@folder}"
    @page_id = params[:pid]    #page index no 0..max
    p "show page_id=#{@page_id}"
    @subpage = params[:spid]   #sub page no 0..9
    p "show subpage_id=#{@subpage}"
    @fileid  = params[:fn]     #fileid "0"=no  "filename"
    p "show field=#{@fileid}"

    #read mokuji content.txt in book
    readmokujifile(@folder)
    #Camera からfilenameが指定されて飛んできた場合 
    if @fileid != "0" then 
      @filename = @fileid   #filename HH-01
      #Filename to page_id
      id = 0
      while @filenames[id.to_i] != @filename and id < @max_page do
        id = id +1
      end
      if id >= @max_page then id = 0 end
      @page_id = id
      p "show camera page_id=#{@page_id}"
    end

    #Dat load to WORK folder
    @filename = @filenames[@page_id.to_i]
    if asset_exists?(@folder + ".zip")then
      #unzip data
      p "SHOW:Unzip : #{@filename}"
      unzippagedata(@folder, @filename)
    else
      #copy Data to WORKfolder for debug
      p "SHOW:Copy : #{@filename}"
      copyDataToWorkForDebug(@folder, @filename)
    end




    #check sub page data exist
    nxtPlane = @subpage.to_i + 1;
    @filename = @filenames[@page_id.to_i]
#    @folderN = @folder + "/" + @folder + "#{nxtPlane}/"
    @folderN = @folder + "/" + @folder + "#{nxtPlane}/"+ @filename + "/"
    @audio_filename = @folderN + @filename + ".mp3"
    @text_filename =  @folderN + @filename + ".txt"
    @subpage_disabel = false
    @next_subpage_audio_file_exist = false;

    if asset_exists?(@audio_filename) or asset_exists?(@text_filename) then
      #enable sub page button
      @next_subpage_audio_file_exist = true;
      @tenjiModeBtnTitle = "解説"+"#{nxtPlane}へ"
    else
      #subpage audio file nothing
      @next_subpage_audio_file_exist = false;
      @tenjiModeBtnTitle = "本文へ" 
      if @subpage == "0" then
        @subpage_disable = true
      end
    end

    #define data folder
    #@folder0 = @folder + "/" + @folder + "0/"
    @folder0 = @folder + "/" + @folder + "0/" + @filename + "/"
    @folderN = @folder + "/" + @folder + "#{@subpage}/"+ @filename + "/"
    if @subpage == "0" then
      #main page
      p "@main page:#{@subpage}"
      @file_path = @folder0 + @filename
      @image_filename = @file_path + ".jpg"
      @audio_filename = @file_path + ".mp3"
      @text_filename =  @file_path + ".txt"  
      @file_path = @folder0
    else
      #sub page
      @file_path = @folderN + @filename
      @image_filename = @file_path + ".jpg"
      @audio_filename = @file_path + ".mp3"
      @text_filename =  @file_path + ".txt"  
      if asset_exists?(@image_filename)==false then 
        #ないので代替
        @image_filename = @folder0 + @filename + ".jpg" 
      end
      @file_path = @folderN
    end
    
    @text_content = ""
    @audio_file_exist = 0
    @text_file_exist = 0
    @imagemap = []
    @max_imagemap = -1;

    if asset_exists?(@audio_filename) then
      @audio_file_exist = 1 
    end
    if asset_exists?(@text_filename) then
        readtextfile(@text_filename, @file_path)
        p "text_file:#{@text_filename}"
        p "text:#{@text_content}"
        @text_file_exist = 1
    end
    $now_page_id = @page_id
    #prev page no
    @prev_disable = "";
    @prev_id = @page_id.to_i - 1
    if (@prev_id.to_i < 0 ) then
      @prev_id = 0
      @prev_disable = "disabled";
    end

    #next page no    
    @next_disable = "";
    @next_id = @page_id.to_i + 1
    if (@next_id.to_i > @max_page.to_i) then
      @next_id = @max_page.to_i;
      @next_disable = "disabled";
    end
    if @next_subpage_audio_file_exist == true then
       @subpage = @subpage.to_i + 1
       p "Last @subpage + 1:#{@subpage}"
    else
      @subpage = 0
      p "Last @subpage set to main:#{@subpage}"
    end


    p "@book_id:#{@book_id}"
    p "@folder :#{@folder}"
    p "@page_id:#{@page_id}"
    p "$now_page_id:#{$now_page_id}"
    p "@next_id:#{@next_id}"
    p "@prev_id:#{@prev_id}"
    p "@subpage:#{@subpage}"
    p "@max_page:#{@max_page}"
    p "@subpage_disable:#{@subpage_disable}"
    p "@file_path     :#{@file_path}"
    p "@image_filename:#{@image_filename}"
    p "@audio_filename:#{@audio_filename}"
    p "@text_filename :#{@text_filename}"
    p "@audio_file_exist:#{@audio_file_exist}"
    p "@text_file_exist :#{@text_file_exist}"
    p "next_subpage_audio_file_exist :#{@next_subpage_audio_file_exist}"
    #p "@imagemap=#{@imagemap}"

    p "**** SHOW END *****"

  end


  #
  # file format
  # (play end time):(speaking text):(imagemap data)
  # 28000:近くに龍清寺があります。:target=100 title=--- shape ---
  # ::target=010,1000,2000 title="茅葺屋根" shape=poly coords=59,414,224,340,225,323,--------
  #
  def readtextfile(txtfile, file_path)
    src = "app/assets/images/" + txtfile
    @text_content = ""      #(speaking text)
    @map_text_content = []
    #@book_content = []
    @imagemap = []
    @imagemap_target = []
    @imagemap_clipboard = []
    @max_imagemap = -1;
    File.open(src, "r").each_line do |line|
      
      if !line.start_with?("#") then
        strs = line.split(":", 3)
        aa=""   #play end time 
        bb=""   #speaking text
        cc=""   #imagemap data
        if (strs[0]!=nil) then aa = strs[0].strip end
        if (strs[1]!=nil) then bb = strs[1].strip end
        if (strs[2]!=nil) then cc = strs[2].strip end #target=010,1000,2000 title="茅葺屋根" shape=poly coords=---
        #p "aa=#{aa}"
        #p "bb=#{bb}"
        #p "cc=#{cc}"
        if aa.blank? or bb.blank?
        else
          #0:abcdefg
          @text_content << bb
          @text_content << '。\n' 
        end
        if !cc.blank? then
          #target=nnn を探す
          dd = cc.index('target=')
          ee = ""    #.mp3
          ltx = ""   #.ltx
          pyt = ""   #.pyt
          if dd!=nil then
            dd1 = cc.index(' ')   #first separator ::target=XXXXX,YYY,ZZZ_
            ee = cc[dd+7..dd1-1]  #ee=XXXXX,YYY,ZZZ
            ff = ee.split(',')    #ff=[XXXXX][YYY][ZZZ]
            gg = file_path+ff[0]+".mp3"
            hh = file_path+ff[0]+".ltx"
            ii = file_path+ff[0]+".pyt"
            if !asset_exists?(gg) then
              #mp3 not found
              if (ff[1] and ff[1].length > 0) then
                ee = ff[0] + "," + ff[1]
              else
                ee = ff[0] + ",TTS"
              end
            end
            if asset_exists?(hh) then
              ltx = ff[0] + ".ltx"
            else
              ltx = ""    #.ltx not found
            end
            if asset_exists?(ii) then
              pyt = ff[0] + ".pyt"
            else
              pyt = ""    #.pyt not found
            end
          end
          @imagemap_target << ee  #.mp3
          if ltx.length > 0 then
            @imagemap_clipboard << ltx  #.ltx
          elsif pyt.length >0 then
            @imagemap_clipboard << pyt  #.pyt
          else
            @imagemap_clipboard << ""   #nothing
          end 
          @imagemap << cc         #target=010 ---
          #p "target mp3=#{ee}"
          #p "target ltx=#{ltx}"
          #p "target pyt=#{pyt}"
        end
      end
    end
    if @imagemap.length > 0 then 
      @max_imagemap = @imagemap.length - 1
    end
#    p "@text_content=#{@text_content}"
    p "@max_imagemap=#{@max_imagemap}"
  end

  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end
end
