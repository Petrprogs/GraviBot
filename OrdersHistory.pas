unit OrdersHistory;

interface

uses Ticker, IniFile, Newtonsoft.Json;

type
  TOrdersHistory = class
  public
    function GetOrdersHistory(side: string): decimal;
  end;

implementation

function OrdersHistory.TOrdersHistory.GetOrdersHistory(side: string): decimal;
begin
  var key := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'apikey', '');
  var secret := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'apisecret', '');
 var market := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'market', '');
  var siganture := new System.Security.Cryptography.HMACSHA256();
  siganture.Key := Encoding.UTF8.GetBytes(secret);
  var unixTime := System.DateTimeOffset.UtcNow.ToUnixTimeMilliseconds;
  var str := 'GET|/api/v2/trades/my.json|access_key=' + key + '&market=' + market + '&tonce=' + unixTime.ToString;
  var sigarr := siganture.ComputeHash(Encoding.UTF8.GetBytes(str));
  var sig := System.BitConverter.ToString(sigarr).Replace('-', string.Empty).ToLower();
  var reqstring := 'https://graviex.net/api/v2/trades/my.json?access_key=' + 
   key +
  '&tonce=' + unixTime.ToString +
  '&signature=' + sig +
  '&market=' + market;
  try
    var request := new System.Net.WebClient;
    var data := request.DownloadData(reqstring);
    var chararr := Encoding.UTF8.GetChars(data);
    var output := new string(chararr);
    var xml := JsonConvert.DeserializeXmlNode(string.Format('{{' + 'HistoryOrders' + ': {0} }}',output), 'TradesHistory');  
      for var RecNum:= xml.GetElementsByTagName('market').Count  - 1 downto 0 do begin
        if xml.GetElementsByTagName('market')[RecNum].InnerText = market then
        begin
          if xml.GetElementsByTagName('side')[RecNum].InnerText = side then
             Result := decimal.Parse(xml.GetElementsByTagName('price')[RecNum].InnerText);
          end;
        end;
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