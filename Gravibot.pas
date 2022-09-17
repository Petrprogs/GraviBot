uses IniFile, System, System.IO, System.Net.Security,
System.Net, System.Xml, Ticker, CreateOrders, GetOrders, 
Loger, CoinAvailabilty, OrdersHistory, Depth;

var
  networkerror := true;
  sellprice: decimal;
  buyprice : decimal;
  bidscount : integer;
  GetOrder := (new GetOrders.TGetOrders).GetOrders;
  Tickers := new Ticker.TTicker;
  NewOrders := new CreateOrders.TCreateOrders;
  WriteToLog := new Loger.TLoger;
  CurrencyAvail := new CoinAvailabilty.TCoinAvailabilty;
  TradesHistory := new OrdersHistory.TOrdersHistory;
  MarketDepth := new Depth.TDepth;

procedure bot(); //Main Procedure
begin
  var price := Tickers.GetMarketTicker[2];
  var coin1 := CurrencyAvail.GetCoinBalance('btc');
  var coin2 := CurrencyAvail.GetCoinBalance('boli');
  var maxboliamount := (new IniFile.TIniFile('Parameters.ini')).ReadString('MainParameters', 'maxboliamount', '');
  sellprice := Tickers.GetMarketTicker[0] - decimal.Parse('0.000000001');
  var lastbid := TradesHistory.GetOrdersHistory('bid');
  var depthasks := MarketDepth.GetMarketDepth('asks', 0);
  var firstask := decimal.Parse(depthasks.GetElementsByTagName('asks')[10].FirstChild.InnerText) - decimal.Parse(depthasks.GetElementsByTagName('asks')[12].FirstChild.InnerText);
  var secondask := decimal.Parse(depthasks.GetElementsByTagName('asks')[7].FirstChild.InnerText) - decimal.Parse(depthasks.GetElementsByTagName('asks')[10].FirstChild.InnerText);
  if firstask = decimal.Parse('0.000000001') then
  begin
    if secondask = decimal.Parse('0.000000001') then
      else
    begin
      sellprice := decimal.Parse(depthasks.GetElementsByTagName('asks')[10].FirstChild.InnerText) +  decimal.Parse('0.000000001');    
    end;
  end
     else
  begin
    sellprice := decimal.Parse(depthasks.GetElementsByTagName('asks')[10].FirstChild.InnerText) -  decimal.Parse('0.000000001');
  end;
  begin
    if sellprice <  lastbid then
      while sellprice <= lastbid do
        sellprice := sellprice + decimal.Parse('0.000000003');
    Writeln('Current Sell Price : ' + sellprice.ToString);
    if coin2 <= 1 then
      Writeln('BOLI count is very small! Skip ask creation...')
    else
      begin
    Writeln('Try Making Sell Order!');
    Writeln(NewOrders.NewOrder('sell', coin2, sellprice));
    Console.Beep();
    end;
  end;
  begin
    buyprice := Tickers.GetMarketTicker[1] + decimal.Parse('0.000000001');
    var depthbids := MarketDepth.GetMarketDepth('bids', 0);
    var firstbid := decimal.Parse(depthbids.GetElementsByTagName('bids')[0].FirstChild.InnerText) - decimal.Parse(depthbids.GetElementsByTagName('bids')[3].FirstChild.InnerText);
    var secondbid := decimal.Parse(depthbids.GetElementsByTagName('bids')[3].FirstChild.InnerText) - decimal.Parse(depthbids.GetElementsByTagName('bids')[6].FirstChild.InnerText);
    if firstbid = decimal.Parse('0.000000001') then
    begin
      if secondbid = decimal.Parse('0.000000001') then
      else
      begin
        buyprice := decimal.Parse(depthasks.GetElementsByTagName('bids')[6].FirstChild.InnerText) +  decimal.Parse('0.000000001');    
      end;
    end
     else
    begin
      buyprice := decimal.Parse(depthasks.GetElementsByTagName('bids')[0].FirstChild.InnerText) -  decimal.Parse('0.000000001');
    end;
    Writeln('Current Buy Price :  ' + buyprice.ToString);
    if (new IniFile.TIniFile('Parameters.ini')).ReadInteger('MainParameters', 'maxbidcount', 1) = 1 then
    begin
      for var i:= 0 to GetOrder.GetElementsByTagName('side').Count - 1 do
        begin
      if GetOrder.GetElementsByTagName('side')[i].InnerText = 'buy' then
        bidscount := bidscount +1;
      end;
      end;
      if bidscount > 0 then
        Writeln('Order count > 0! Skip bid creation...')
        else
          begin
    Writeln('Try Making Buy Order!');
    Writeln(NewOrders.NewOrder('buy', Decimal.Parse(maxboliamount), buyprice));
    Console.Beep();
    Writeln('Buy order succesfuly created');
  end;
  end;
end;

begin
  Console.Title := 'Graviex Pascal Bot';
  repeat
    try
      begin
        while True do
        begin
          //networkerror:= false;
          bot; 
          Sleep(60000); //600000!!!
          Console.Clear;
        end;
      end;
    
    except
      on ex: System.Net.WebException do
      begin
        networkerror := true;
        Writeln('Network error! Trying again...' + ex.Message);
        Sleep(1000);
        //Console.Clear;
      end;
    end;
  until networkerror = false;
end.