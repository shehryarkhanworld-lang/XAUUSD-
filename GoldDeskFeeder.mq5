#property strict
input string ServerURL  = "https://YOURSITE.netlify.app/api/ingest";
input string Key        = "CHANGE_ME";          // same as GOLD_KEY on Netlify
input string GoldSymbol = "XAUUSD";             // your broker's gold symbol (e.g. GOLD, XAUUSDm)
input int    SendSeconds = 10;
input int    LtfBars = 150;                      // M15 candles
input int    HtfBars = 80;                       // bias candles
input ENUM_TIMEFRAMES HtfFrame = PERIOD_H1;      // H1 or H4

string Arr(ENUM_TIMEFRAMES tf, int n)
{
   MqlRates r[]; ArraySetAsSeries(r, false);
   int got = CopyRates(GoldSymbol, tf, 0, n, r);
   if(got <= 0) return "[]";
   string s = "[";
   for(int i = 0; i < got; i++)
   {
      if(i > 0) s += ",";
      s += StringFormat("{\"o\":%.5f,\"h\":%.5f,\"l\":%.5f,\"c\":%.5f}", r[i].open, r[i].high, r[i].low, r[i].close);
   }
   return s + "]";
}
int OnInit(){ SymbolSelect(GoldSymbol, true); EventSetTimer(SendSeconds); return INIT_SUCCEEDED; }
void OnDeinit(const int reason){ EventKillTimer(); }
void OnTimer()
{
   string body = "{\"ltf\":" + Arr(PERIOD_M15, LtfBars) + ",\"htf\":" + Arr(HtfFrame, HtfBars) + "}";
   char data[], res[]; string rh;
   StringToCharArray(body, data, 0, StringLen(body), CP_UTF8);
   int code = WebRequest("POST", ServerURL + "?key=" + Key, "Content-Type: application/json\r\n", 5000, data, res, rh);
   if(code == -1) Print("GoldDeskFeeder: WebRequest failed, err=", GetLastError(), " - add the URL in Tools > Options > Expert Advisors > Allowed URLs");
   else if(code != 200) Print("GoldDeskFeeder: server replied ", code);
}
