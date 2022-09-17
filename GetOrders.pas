unit GetOrders;

interface

uses IniFile, Newtonsoft.Json;

type
  TGetOrders = class
  public
    function GetOrders(): System.Xml.XmlDocument;
  end;

implementation

function GetOrders.TGetOrders.GetOrders: System.Xml.XmlDocument;
begin
  var key := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'apikey', '');
  var secret := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'apisecret', '');
  var siganture := new System.Security.Cryptography.HMACSHA256();
  siganture.Key := Encoding.UTF8.GetBytes(secret);
  var  unixTime := System.DateTimeOffset.UtcNow.ToUnixTimeMilliseconds;
  var str := 'GET|/webapi/v3/orders.json|access_key=' + key + '&market=all' + '&tonce=' + unixTime.ToString;
  var sigarr := siganture.ComputeHash(Encoding.UTF8.GetBytes(str));
  var sig := System.BitConverter.ToString(sigarr).Replace('-', string.Empty).ToLower();
  var reqstring := 'https://graviex.net/webapi/v3/orders.json?access_key=' + 
   key +
  '&tonce=' + unixTime.ToString +
  '&signature=' + sig +
  '&market=all';
  try
    var request := new System.Net.WebClient;
    var data := request.DownloadData(reqstring);
    var chararr := Encoding.UTF8.GetChars(data);
    var output := new string(chararr);
    var xml := JsonConvert.DeserializeXmlNode(string.Format('{{' + 'Orders' + ': {0} }}', output), 'ListOrders');
    Result := xml;
    xml.Save('OrdersWait.xml');
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