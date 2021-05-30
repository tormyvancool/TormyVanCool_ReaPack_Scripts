--[[
@description Extracts and exports VSTs and VSTIs from reaper-vstplugins64.ini, in HTML and CSV format on a Project Folder
@author Tormy Van Cool
@version 1.1
@screenshot
@changelog:
v1.0 (30 may 2021)
  + Initial release
v1.1 (31 may 2021)
  + Save status of HTML File
  + Retrieve status of HTML file
]]
reaper.ShowConsoleMsg('')
local version = "1.1"
local proj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
local path = reaper.GetResourcePath()..'\\reaper-vstplugins64.ini'
local FileName = proj_path.."/REAPER.VSTinstalled"
local VST_RegisterHTML = FileName..".html"
local VST_RegisterCSV = FileName..".csv"
local VST_RegisterJSN = "REAPER.VSTinstalled.json"
local date = os.date("%Y-%m-%d %H:%M:%S")
local VST_RegisterJSN = VST_RegisterJSN:gsub( "\\", "/")

local HeaderHTML = [[
<!doctype html>
<html>
  <head>
    <title>REAPER VST/VSTI INSTALLED EXTRACTOR</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Arimo&display=swap" rel="stylesheet">
    <style>
      th, td, span {font-family: 'Arimo', sans-serif;}
      .table_header{background: #0057a1 !important; color: white;}
      form {width: 70%}
      table{margin-bottom: 12px;}
      #title, #rows {width: 1320px;}
      th.header { background: #2db1ef; color: white; font-size: 51px; position: relative; padding: 30px; }
      .table_title { margin-top: 10px; background: linear-gradient( 48deg , #2dbbff, transparent); font-weight: bolder; color: #ca5603; font-size: 22px; }
      tr:nth-child(even) td.solo {background: #ffc107;text-align: center; }   
      tr:nth-child(odd) td.solo {background: #ffd149;text-align: center; }
      tr:nth-child(even) td.mute { background: red;text-align: center;color: white; }
      tr:nth-child(odd) td.mute {background: #ef5656;text-align: center;color: white; }
      tr:nth-child(even) td.disabled { background: #018aff; color: white; text-align: center; }
      tr:nth-child(odd) td.disabled { background: #37a3ff; color: white; text-align: center; }
      tr:nth-child(even) td.enabled { background: #1ec600; color: white; text-align: center; }
      tr:nth-child(odd) td.enabled { background: #2bec08; color: white; text-align: center; }
      tr:nth-child(even) {background: #dddddd}
      tr:nth-child(odd) {background: #f1f1f1}
      th, tr, td {padding: 10px 20px 10px 20px; position: relative;}
      thead th:first-of-type{ border-top-left-radius: 10px; }
      thead th:last-of-type{ border-top-right-radius: 10px; }
      tr:last-child td:first-child { border-bottom-left-radius: 10px; }
      tr:last-child td:last-child { border-bottom-right-radius: 10px; }
      .center { margin-left: auto; margin-right: auto; }
      .centertext {text-align: center;}
      .left{text-align: left;}
      sub { font-size: 12px; float: right; position: absolute; bottom: 10px; right: 10px; }
      .spacer{width: 100%;height:50px}
      .right{text-align: right;}
      button.file-save, button.file-load, button.reset { position: absolute; width: 133px; height: 50px; left: 31px; }
      button.file-save { top: 20px; }
      button.file-load { top: 75px; }
      button.reset { top: 130px; }
      .checkbox {    width: 15px;    padding: 0 28px;}
      .name {    width: 770px;}
      .file {    width: 390px;}
      div#buttons { position: fixed; left: 60px; top: 150px; background: #0057a1; width: 200px; height: 200px; border-radius: 0 0 10px 10px; }
      span#info { background: red; position: fixed; left: 60px; top: 11px; width: 180px; border-radius: 10px 10px 0 0; height: 119px; padding: 10px; text-align: center; color: white; font-weight: bold; }
      table#rows { position: relative; top: 153px; }
      table#title { position: fixed; top: 0px; left: 291px; z-index: 1; }
    </style>
    <script>

      $(document).ready(function(){

        //prevent the form from submitting on button click
      $('form button').on('click', e => e.preventDefault());
      //open file loader
      $('button.file-load').on('click', function() {
        $('.file-loader').click();
      });
      
      //uncheck all checkboxes
      $('button.reset').on('click', function() {
        $('table input[type="checkbox"]').each(function() {
          this.checked = false;
        });
      });
      
      //convert checkbox states to json and save
      $('button.file-save').on('click', function() {
        let a = document.createElement('a'),
            states = {};
            
        $('table input[type="checkbox"]').each(function() {
          states[this.name] = this.checked
        });
            
        a.setAttribute('href', 'data:text/plain;charset=utf-8,' + JSON.stringify(states));
        a.setAttribute('download', ']]..VST_RegisterJSN..[[');
        a.click();
        a.remove();
      });
      
      //load saved states
      $('.file-loader').on('change', function() {
        let reader = new FileReader();
      
        reader.onload = function(file) {
          $.each(JSON.parse(file.target.result), function(id, state) {
            $(`form input[name="${id}"]`).prop('checked', state);
          });
        };
      
        reader.readAsText(this.files[0]);
      });

    });
    </script>
  </head>
  <body>
    <table id="title" class="center">
      <thead>
        <tr>
          <th colspan="3" class="header">REAPER VST/VSTi INSTALLED EXTRACTOR<sub>]]..date..[[ - v.]]..version..[[ by Tormy Van Cool</sub></th>
        <tr>
          <th class="table_header checkbox">&nbsp;</th>
          <th class="table_header name">VST/VSTi NAME (Manufacturer)</th>
          <th class="table_header file">Related FILE</th>
        </tr>
      </thead>
    </table>
 <form  class="center" action="#" method="get" id="TableForm">
  <div id="buttons">
    <button class="file-save">Save</button>
    <button class="file-load">Load</button>
    <!-- if <input type="file"> isn't hidden, it shows the current file selected -->
    <input class="file-loader" type="file" hidden>
    <button class="reset">Reset</button>
  </div>
    <span id="info" class="centertext">IMPORTANT</br></br>You MUST HAVE internet connection</br>to make correctly</br>work this page!!!</span>
    <table id="rows" class="center">

      <tbody>
]]
local FooterHTML = [[
      </tbody> 
    </table>
    </form>
  </body>
</html>]]
local HeaderCSV = "REAPER,VST/VSTi INSTALLED EXTRACTOR\nVersion:,"..version.."\nby:,Tormy Van Cool\nDate:,"..date.."\n\n"
HeaderCSV = HeaderCSV.."CHECK,VST/VSTi NAME (Manufacturer),Related FILE\n"


---------------------------------------------
-- FILES
---------------------------------------------
local handle = io.open(path, "r")
local HTML = io.open(VST_RegisterHTML, 'w')
local CSV = io.open(VST_RegisterCSV, 'w')



function main()
  HTML:write(HeaderHTML)
  CSV:write(HeaderCSV)
  local lineHTML = ''
  local lineCSV = ''
  local n = 1
  for _ in handle:lines() do
    s = handle:read("*l")

    if _ == nil then 
        handle:close() 
      else
     
        if s ~= nil then 
          match = string.gsub(s, "%,", "|",2)
          VST_dll,VST_Integer1,VST_Integer2,VST_Name = match:match("^(.+)=(.+)|(.+)|(.+)$")
        end

        if VST_Name ~= nil and VST_dll ~= nil then
          VST_Name = string.gsub(VST_Name, "%,", " / ")
          
          lineHTML = lineHTML..'<tr><td><input type="checkbox" name="checkfield'..n..'" class="checkbox"></td><td class="name">'..VST_Name..'</td><td class="file">'..VST_dll..'</td></tr>'
          lineCSV = lineCSV..','..VST_Name..','..VST_dll..'\n' 
          n=n+1
        end
    end
 end

  HTML:write(lineHTML)
  CSV:write(lineCSV)
  HTML:write(FooterHTML)
  HTML:close()
  CSV:close()
end
main()