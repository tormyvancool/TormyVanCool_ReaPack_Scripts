--[[
@description Extracts and exports VSTs and VSTIs from reaper-vstplugins64.ini, in HTML and CSV format on a Project Folder
@author Tormy Van Cool
@version 1.0
@screenshot
@changelog:
v1.0 (30 may 2021)
  + Initial release
]]
reaper.ShowConsoleMsg('')
local version = "1.0"
local proj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
local path = reaper.GetResourcePath()..'\\reaper-vstplugins64.ini'
local FileName = proj_path.."/REAPER.VSTinstalled"
local VST_RegisterHTML = FileName..".html"
local VST_RegisterCSV = FileName..".csv"
local VST_RegisterJSN = FileName..".json"
local date = os.date("%Y-%m-%d %H:%M:%S")
VST_RegisterJSN = VST_RegisterJSN:gsub( "\\", "/")

local HeaderHTML = [[
<!doctype html>
<html>
  <head>
    <title>REAPER VST/VSTI INSTALLED EXTRACTOR</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Arimo&display=swap" rel="stylesheet">
    <style>
      th, td {font-family: 'Arimo', sans-serif;}
      .table_header{background: #0057a1 !important; color: white;}
      table{margin-bottom: 12px; width:70%}
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
    </style>
    <script>
    //
    // jQuery Plugin
    //
    ;(function($) {
        $.fn.toJSON = function() {
            var $elements = {};
            var $form = $(this);
            $form.find('input, select, textarea').each(function(){
              var name = $(this).attr('name')
              var type = $(this).attr('type')
              if(name){
                var $value;
                if(type == 'radio'){
                  $value = $('input[name='+name+']:checked', $form).val()
                } else if(type == 'checkbox'){
                  $value = $(this).is(':checked')
                } else {
                  $value = $(this).val()
                }
                $elements[$(this).attr('name')] = $value
              }
            });
            return JSON.stringify( $elements )
        };
        $.fn.fromJSON = function(json_string) {
            var $form = $(this)
            var data = JSON.parse(json_string)
            $.each(data, function(key, value) {
              var $elem = $('[name="'+key+'"]', $form)
              var type = $elem.first().attr('type')
              if(type == 'radio'){
                $('[name="'+key+'"][value="'+value+'"]').prop('checked', true)
              } else if(type == 'checkbox' && (value == true || value == 'true')){
                $('[name="'+key+'"]').prop('checked', true)
              } else {
                $elem.val(value)
              }
            })
        };
    }( jQuery ));
    
    //
    // DEMO CODE
    // 
    $(document).ready(function(){
       $("#_save").on('click', function(){
         console.log("Saving form data...")
         var data = $("form#myForm").toJSON()
         console.log(data);
         //localStorage['form_data'] = data;
         function saveText(text, filename){
           var a = document.createElement('a');
           a.setAttribute('href', 'data:text/plain;charset=utf-8,'+encodeURIComponent(text));
           a.setAttribute('download', filename);
           a.click()
         }
         saveText( data, "REAPER.VSTinstalled.json" );

         
         return false;
       })
       
       $("#_load").on('click', function(){
         if(localStorage['form_data']){
           console.log("Loading form data...")
           //console.log(JSON.parse(localStorage['form_data']))
           //console.log(JSON.parse('file:///]]..VST_RegisterJSN..[['))
           

           $("form#myForm").fromJSON($.getJSON("file:///]]..VST_RegisterJSN..[["))
         } else {
           console.log("Error: Save some data first")
         }
         
         return false;
       })
    });
    </script>
  </head>
  <body>
  <!--
  <form  class="center" action="#" method="get" id="myForm">
  <button id="_save">Save</button>
  <button id="_load">Load</button>
  <input type="reset">
  -->
    <table class="center">
      <thead>
        <tr>
          <th colspan="2" class="header">REAPER VST/VSTi INSTALLED EXTRACTOR<sub>]]..date..[[ - v.]]..version..[[ by Tormy Van Cool</sub></th>
        <tr>
          <!-- <th class="table_header">&nbsp;</th> -->
          <th class="table_header">VST/VSTi NAME (Manufacturer)</th>
          <th class="table_header">Related FILE</th>
        </tr>
      </thead>
      <tdoby>
]]
local FooterHTML = [[
      </tbody> 
    </table>
    <!--
    <button id="_save">Save</button>
    <button id="_load">Load</button>
    <input type="reset">
    -->
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
  local n = 0
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
          lineHTML = lineHTML..'<tr><!--<td><input type="checkbox" name="checkfield'..n..'"></td>--><td class="name">'..VST_Name..'</td><td>'..VST_dll..'</td></tr>'
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
