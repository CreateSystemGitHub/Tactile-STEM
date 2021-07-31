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
#  @@title = ""

  #####################################

    
  
  
  #####################################
  def cashfile
    @max_cashFile = 0
    @cash_FilePath = []
    readcashfilename("HH")
    readcashfilename("TT")

    @max_cashFile = @cash_FilePath.length - 1;
    p "max_cashFile=#{@max_cashFile}"
  end

  def readcashfilename(folder)
    nex = @cash_FilePath.length
    readmokujifile(folder)
    for i in 0..@filenames.length-1  do
      pagename = @filenames[i]
      if pagename != nil then
        f_folder = folder + "/" + folder + "0/" + pagename + "/"
        image_filename = f_folder + pagename + ".jpg"
        audio_filename = f_folder + pagename + ".mp3"
        text_filename =  f_folder + pagename + ".txt"
        if asset_exists?(image_filename) then @cash_FilePath << image_filename end
        if asset_exists?(audio_filename) then @cash_FilePath << audio_filename end
        if asset_exists?(text_filename)  then
          @cash_FilePath << text_filename  
          #find mp3 files

        end

      end
    end
    p "path1=#{@cash_FilePath[nex]}"
    p "path2=#{@cash_FilePath[nex+1]}"
    p "path3=#{@cash_FilePath[nex+2]}"

  end


  #####################################
  def readmokujifile(folder)
    require "csv"
    path = "app/assets/images/" + folder + "/"
    src  = path + "Contents.txt"
    @pagenos = []
    @filenames = []
    @contents = []
    CSV.foreach(src, { col_sep: ":" }) do |line1|
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
    p "show field=#{@field}"

    #read mokuji content.txt in book
    readmokujifile(@folder)
    #Camera からfilenameが指定されて飛んできた場合 
    if @fileid!="0" then 
      @filename = @fileid   #filename HH-01
      #Filename to page_id
      id = 0
      while @filenames[id.to_i] != @filename and id < @max_page do
        id = id +1
      end
      if id >= @max_page then id = 0 end
      @page_id = id
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
  # ::target=010 title="茅葺屋根" shape=poly coords=59,414,224,340,225,323,--------
  #
  def readtextfile(txtfile, file_path)
    src = "app/assets/images/" + txtfile
    @text_content = ""      #(speaking text)
    @map_text_content = []
    #@book_content = []
    @imagemap = []
    @imagemap_target = []
    @max_imagemap = -1;
    File.open(src, "r").each_line do |line|
      
      if !line.start_with?("#") then
        strs = line.split(":", 3)
        aa=""   #play end time 
        bb=""   #speaking text
        cc=""   #imagemap data
        if (strs[0]!=nil) then aa = strs[0].strip end
        if (strs[1]!=nil) then bb = strs[1].strip end
        if (strs[2]!=nil) then cc = strs[2].strip end
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
          ee = nil
          if dd!=nil then
            dd1 = cc.slice(dd+7,20)
            dd2 = dd1.index(' ')      #first separator target=XXXXX,YYY,ZZZ_
            ee= cc.slice(dd+7,dd2)    #ee = target
            ff = ee.split(',')
            gg = file_path+ff[0]+".mp3"
            if !asset_exists?(gg) then
              if (ff[1] and ff[1].length > 0) then
                ee = ff[0] + "," + ff[1]
              else
                ee = ""
              end
            end
          end
          p "target =#{ee}"
          @imagemap_target << ee
          @imagemap << cc
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
