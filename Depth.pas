unit Depth;

interface

uses IniFile, Newtonsoft.Json;

type
  TDepth = class
  public
    function GetMarketDepth(side: string; index: integer): System.Xml.XmlDocument;
  end;

implementation

function Depth.TDepth.GetMarketDepth(side: string; index: integer): System.Xml.XmlDocument;
begin
  var key := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'apikey', '');
  var secret := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'apisecret', '');
  var market := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'market', '');
  var reqstring := 'https://graviex.net/api/v2/depth.json?market=' + market + '&limit=5';
  try
    var request := new System.Net.WebClient;
    var data := request.DownloadData(reqstring);
    var chararr := Encoding.UTF8.GetChars(data);
    var output := new string(chararr);
    var xml := JsonConvert.DeserializeXmlNode(output, 'TradesHistory');  
    Result := xml;
  except
    on ex: System.Net.WebException do
    begin
      
      if ex.Response is System.Net.WebResponse then
      begin
        var Response := ex.Response;
        var stream := Response.GetResponseStream;
        var Reader := new System.IO.BinaryReader(Stream);
        var res := Reader.ReadBytes(stream.Length);
        var chararr := Encoding.UTF8.GetChars(res);
        var output := new string(chararr);
        Writeln(output);
      end
      else
        Writeln(ex.Message);
    end;
  end;
end;
end.