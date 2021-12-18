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
  # Release時には zip data を解凍しながら運用するが、
  # Debug時には zipを消去し、実データそのものを使用する。
  # Release時には、実データをzip化すること。
  #################################################
  def isDebugMode(folder)
    if File.exist?("app/assets/images/" + folder + ".zip") then
      p "isDebugMode:File.exist? : true :" +folder +".zip"
      return false;
    else
      p "isDebugMode:File.exist? : false :" +folder +".zip"
      return true
    end
  end
  #################################################
  # For debug
  # Copy data to WORK folder
  #################################################
  def copyContentsFileToWorkForDebug(folder)
    require 'fileutils'
    src = "app/assets/images/" + folder + "/Contents.txt"
    dst = "app/assets/images/WORK/" + folder 
    FileUtils.mkdir_p(dst)   #make folder
    FileUtils.cp(src, dst)
  end
  def copyPageDataToWorkForDebug(folder, pagename)
    require 'fileutils'
    dst = "app/assets/images/WORK"
    FileUtils.rm_rf(dst)     #delete folder and files
    begin
      src = "app/assets/images/" + folder + "/" + folder + "0/" + pagename
      dst = "app/assets/images/WORK"
      dst2 = dst + "/" + folder + "/" + folder + "0/"
      #FileUtils.rm_rf(dst)     #delete folder and files
      FileUtils.mkdir_p(dst2)   #make folder
      FileUtils.cp_r(src, dst2)
    rescue => e
      p e.message
    ensure
      p "copyPageDataToWorkForDebug():#{src}"
    end
    begin
      src = "app/assets/images/" + folder + "/" + folder + "1/" + pagename
      dst = "app/assets/images/WORK"
      dst2 = dst + "/" + folder + "/" + folder + "1/"
      #FileUtils.rm_rf(dst)     #delete folder and files
      FileUtils.mkdir_p(dst2)   #make folder
      FileUtils.cp_r(src, dst2)
    rescue => e
      p e.message
    ensure
      p "copyPageDataToWorkForDebug():#{src}"
    end

  end
  ########################################################
  #  unzip book data to WORK folder
  # ex) unzippagedata(zipname, pagename)
  #   zipname: 'HH.zip'
  #             HH/HH0/HH-1/*.jpg, *.mpg, *.txt ---
  #             HH/Contents.txt
  #   pagename: 'HH-10' or nil means 'NN/Content.txt' only
  #########################################################
  def unzipPageData(zipname, pagename)
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
  #################################################
  # Copy 'Contents.txt' to WORK folder
  #   ==> assets/images/WORK/(folder)/Contents.txt
  #################################################
  def copyContentsFileToWork(folder)
    if !isDebugMode(folder) then unzipPageData(folder, nil) 
    else
      copyContentsFileToWorkForDebug(folder)
    end
  end
  #########################################################
  # Copy page data to WORK folder
  #   ==> assets/images/WORK/(folder)/(folder)0/pagename
  #########################################################
  def copyPageDataToWork(folder, pagename)
    if !isDebugMode(folder) then unzipPageData(folder, pagename)
    else 
      copyPageDataToWorkForDebug(folder, pagename)
      copyContentsFileToWorkForDebug(folder)
    end
    p "copyPageDataToWork() done!"
  end

  #################################################
  # read Mokuji file
  #   Contents.txt ファイルを解析し以下を作成する。
  #   以下のパラメータで、mokuji.htmlを表示する。
  #   @pagenos[],@filenames[],@contents[],@max_page
  #################################################
  def readmokujifile(folder)
    #Contents.txt fileをWORK下にコピーする。
#    copyContentsFileToWork(folder)

    require "csv"
#    src = "app/assets/images/WORK/"+ folder + "/Contents.txt"
    src = "app/assets/images/"+ folder + "/Contents.txt"
    @pagenos = []
    @filenames = []
    @contents = []
    CSV.foreach(src, encoding:"UTF-8", col_sep: ":" ) do |line1|
      aa = line1[0]
      bb = line1[1]
      cc = line1[2]
      if aa.blank? or bb.blank? or cc.blank?
      else
        if !aa.start_with?("#") then
          @pagenos << aa.strip
          @filenames << bb.strip
          @contents << cc.strip
        end
      end
    end
    @max_page = @pagenos.length - 1
  end

  #####################################
  # index(index.html)
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
  # 目次(mokuji.html)
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

    #read mokuji Contents.txt in book
    readmokujifile(@folder)
    @subpage = 0
    @@book_id = @book_id
    p "Mokuji:page_id=#{@page_id}, sub_page=#{@subpage}"
    p "**** MOKUJI END *****"
  end
 
  ###########################################################################
  # 本文(show.html)
  # tactile_show_path(book_id:@book_id, pid:@page_id, spid:'0', fn:'0' )
  #   :book_id  0,1,2 ---       @folder = @@book_folder[book_id]
  #   :pid      0,1,2 ---       @filename = @filenames[pid]
  #   :spid     0,1,2 --- 9     @subpage
  #   :fn       '0','filename'  @file_id Camera からfilenameが指定されてきた場合
  ###########################################################################
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
    @file_id  = params[:fn]     #@file_id "0"=no  "filename"
    p "show field=#{@file_id}"

    #read mokuji content.txt in book
    readmokujifile(@folder)
    #Camera からfilenameが指定されて飛んできた場合 
    if @file_id != "0" then 
      @filename = @file_id   #filename HH-01
      #Filename to page_id
      id = 0
      while @filenames[id.to_i] != @filename and id < @max_page do
        id = id +1
      end
      if id >= @max_page then id = 0 end
      @page_id = id
      p "show camera page_id=#{@page_id}"
    end

    #Page data load to WORK folder
    @filename = @filenames[@page_id.to_i]
#    copyPageDataToWork(@folder, @filename)

    #check sub page data exist
    nxtPlane = @subpage.to_i + 1;
#    @folderN = 'WORK/' + @folder + "/" + @folder + "#{nxtPlane}/"+ @filename + "/"  #WORK/HH/HH1/HH-10/
    @folderN = @folder + "/" + @folder + "#{nxtPlane}/"+ @filename + "/"  #HH/HH1/HH-10/
    @audio_filename = @folderN + @filename + ".mp3"
    @text_filename =  @folderN + @filename + ".txt"
    @subpage_disabel = false
    @next_subpage_audio_file_exist = false;
    if file_exists?(@audio_filename) or file_exists?(@text_filename) then
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

    #define data folder and each path
#    @folder0 = 'WORK/' + @folder + "/" + @folder + "0/" + @filename + "/"
    @folder0 = @folder + "/" + @folder + "0/" + @filename + "/"
#    @folderN = 'WORK/' + @folder + "/" + @folder + "#{@subpage}/"+ @filename + "/"
    @folderN = @folder + "/" + @folder + "#{@subpage}/"+ @filename + "/"
    if @subpage == "0" then
      #main page  WORK/HH/HH0/HH-10/
      p "@main page:#{@subpage}"
      @file_path = @folder0 + @filename       #WORK/HH/HH0/HH-10/HH-10
      @image_filename = @file_path + ".jpg"   #WORK/HH/HH0/HH-10/HH-10.jpg
      @audio_filename = @file_path + ".mp3"   #WORK/HH/HH0/HH-10/HH-10.mp3
      @text_filename =  @file_path + ".txt"   #WORK/HH/HH0/HH-10/HH-10.txt
      @file_path = @folder0
    else
      #sub page 1-9  WORK/HH/HHn/HH-10/
      @file_path = @folderN + @filename       #WORK/HH/HHn/HH-10/HH-10
      @image_filename = @file_path + ".jpg"   #WORK/HH/HHn/HH-10/HH-10.jpg
      @audio_filename = @file_path + ".mp3"   #WORK/HH/HHn/HH-10/HH-10.mp3
      @text_filename =  @file_path + ".txt"   #WORK/HH/HHn/HH-10/HH-10.txt
      if file_exists?(@image_filename)==false then 
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

    if file_exists?(@audio_filename) then
      @audio_file_exist = 1 
    end
    if file_exists?(@text_filename) then
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
            if !file_exists?(gg) then
              #mp3 not found
              if (ff[1] and ff[1].length > 0) then
                ee = ff[0] + "," + ff[1]
              else
                ee = ff[0] + ",TTS"
              end
            end
            if file_exists?(hh) then
              ltx = ff[0] + ".ltx"
            else
              ltx = ""    #.ltx not found
            end
            if file_exists?(ii) then
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

  def file_exists?(path)
    if File.exist?("app/assets/images/" + path) then return true
      return false
    end
  end
end
