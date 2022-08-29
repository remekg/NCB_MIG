

  select nazwa, 
 
  left(nazwa,[dbo].[spacjaPrzed40](nazwa)) as NAZWA1,
  left(substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2,255),[dbo].[spacjaPrzed40](substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2,255))) as NAZWA2
  ,left(substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2+[dbo].[spacjaPrzed40](substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2,255)),255),[dbo].[spacjaPrzed40](substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2+[dbo].[spacjaPrzed40](substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2,255)),255))) as NAZWA3
  ,left(substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2+[dbo].[spacjaPrzed40](substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2,255))+[dbo].[spacjaPrzed40](substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2+[dbo].[spacjaPrzed40](substring(nazwa,[dbo].[spacjaPrzed40](nazwa)+2,255)),255)),255),40) as NAZWA4
  FROM [NCB_MIG].[en].[Stg_PH]

