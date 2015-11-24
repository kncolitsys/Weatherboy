<!---
  Weatherboy v1.0 - A CFC that connects to Weather Underground's XML API feed. Provides current conditions, future forecasts, and weather alerts.
  Tested in Coldfusion 9. Should work fine in Coldfusion 8. Might work in Coldfusion 7.
  (c) 2011 Tony Drake - www.t27duck.com - t27duck@gmail.com
  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
--->
<cfcomponent nickname="Weatherboy" version="1.0" output="false">
  <cfscript>
    // Private Attributes
    VARIABLES.location = '';
  </cfscript>
  
  <cffunction name="init" access="public" returntype="any" output="false" hint="I return an initialized Weatherboy component.">
    <cfargument name="location" type="string" required="true" hint="I am the location zipcode" />
    <cfset VARIABLES.location = ARGUMENTS.location />
    <cfreturn this />
  </cffunction>
  
  <cffunction name="makeCall" access="private" returntype="any" output="false" hint="I make an API call">   
    <cfargument name="url" type="string" required="true" hint="I am the URL to call" />
    <cfhttp
      result = "api_call"
      url = "#ARGUMENTS.url#"
      throwOnError = "yes" 
      timeout = "10" 
      >
    </cfhttp>
    <cfreturn api_call.filecontent>
  </cffunction>
  
  <cffunction name="getCurrent" access="public" returntype="any" output="false" hint="I get current weather conditions">   
    <cfset call_url = "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#VARIABLES.location#">
    <cfset xml = xmlParse(makeCall(call_url))>
    <cfscript>
      cc = StructNew();
      cc.icon = "http://icons-ecast.wxug.com/graphics/conds/#xmlSearch(xml,'current_observation/icon')[1].xmlText#.gif";
      cc.weather = xmlSearch(xml,'current_observation/weather')[1].xmlText;
      cc.temp_f = xmlSearch(xml,'current_observation/temp_f')[1].xmlText;
      cc.temp_c = xmlSearch(xml,'current_observation/temp_c')[1].xmlText;
      cc.relative_humidity = xmlSearch(xml,'current_observation/relative_humidity')[1].xmlText;
      cc.wind_dir = xmlSearch(xml,'current_observation/wind_dir')[1].xmlText;
      cc.wind_mph = xmlSearch(xml,'current_observation/wind_mph')[1].xmlText;
      cc.pressure_mb = xmlSearch(xml,'current_observation/pressure_mb')[1].xmlText;
      cc.pressure_in = xmlSearch(xml,'current_observation/pressure_in')[1].xmlText;
      cc.dewpoint_f = xmlSearch(xml,'current_observation/dewpoint_f')[1].xmlText;
      cc.dewpoint_c = xmlSearch(xml,'current_observation/dewpoint_c')[1].xmlText;
      cc.heat_index_f = xmlSearch(xml,'current_observation/heat_index_f')[1].xmlText;
      cc.heat_index_c = xmlSearch(xml,'current_observation/heat_index_c')[1].xmlText;
      cc.windchill_f = xmlSearch(xml,'current_observation/windchill_f')[1].xmlText;
      cc.windchill_c = xmlSearch(xml,'current_observation/windchill_c')[1].xmlText;
      cc.windchill_c = xmlSearch(xml,'current_observation/windchill_c')[1].xmlText;
      cc.visibility_mi = xmlSearch(xml,'current_observation/visibility_mi')[1].xmlText;
      cc.visibility_km = xmlSearch(xml,'current_observation/visibility_km')[1].xmlText;
    </cfscript>
    <cfreturn cc>
  </cffunction>
  
  <cffunction name="getAlerts" access="public" returntype="query" output="false" hint="I get weather alerts">   
    <cfset call_url = "http://api.wunderground.com/auto/wui/geo/AlertsXML/index.xml?query=#VARIABLES.location#">
    <cfset xml = xmlParse(makeCall(call_url))>

    <cfset alerts = QueryNew("description,date,message")>    
    <cfset alert_nodes = xmlSearch(xml, '/alerts/alert/AlertItem')>
    <cfloop from="1" to="#arrayLen(alert_nodes)#" index="i">
      <cfscript>
        alert = xmlParse(alert_nodes[i]);
        row = QueryAddRow(alerts);
        QuerySetCell(alerts, "description", alert.AlertItem.description[1].xmlText, i);
        QuerySetCell(alerts, "date", alert.AlertItem.date[1].xmlText, i);
        QuerySetCell(alerts, "message", alert.AlertItem.message[1].xmlText, i);
      </cfscript>
    </cfloop>
    <cfreturn alerts>
  </cffunction>
  
  <cffunction name="getForecasts" access="public" returntype="query" output="false" hint="I get weather forecasts">   
    <cfset call_url = "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#VARIABLES.location#">
    <cfset xml = xmlParse(makeCall(call_url))>
    <cfset forecasts = QueryNew("high_f,high_c,low_f,low_c,conditions,icon,pop,title,text")>
    
    <!--- First pass --->
    <cfset forecast_nodes = xmlSearch(xml, '/forecast/simpleforecast/forecastday')>
    <cfloop from="1" to="#arrayLen(forecast_nodes)#" index="i">
      <cfscript>
        forecast = xmlParse(forecast_nodes[i]);
        row = QueryAddRow(forecasts);
        QuerySetCell(forecasts, "high_f", xmlSearch(forecast, 'forecastday/high/fahrenheit')[1].xmlText, i);
        QuerySetCell(forecasts, "high_c", xmlSearch(forecast, 'forecastday/high/celsius')[1].xmlText, i);
        QuerySetCell(forecasts, "low_f", xmlSearch(forecast, 'forecastday/low/fahrenheit')[1].xmlText, i);
        QuerySetCell(forecasts, "low_c", xmlSearch(forecast, 'forecastday/low/celsius')[1].xmlText, i);
        QuerySetCell(forecasts, "conditions", xmlSearch(forecast, 'forecastday/conditions')[1].xmlText, i);
        QuerySetCell(forecasts, "pop", xmlSearch(forecast, 'forecastday/pop')[1].xmlText, i);
        QuerySetCell(forecasts, "icon", "http://icons-ecast.wxug.com/graphics/conds/#xmlSearch(forecast, 'forecastday/icon')[1].xmlText#.gif", i);
      </cfscript>
    </cfloop>
    
    <!--- Second pass --->
    <cfset forecast_nodes = xmlSearch(xml, '/forecast/txt_forecast/forecastday')>
    <cfloop from="1" to="#arrayLen(forecast_nodes)#" index="i">
      <cfscript>
        forecast = xmlParse(forecast_nodes[i]);
        QuerySetCell(forecasts, "text", xmlSearch(forecast, 'forecastday/fcttext')[1].xmlText, i);
        QuerySetCell(forecasts, "title", xmlSearch(forecast, 'forecastday/title')[1].xmlText, i);
      </cfscript>
    </cfloop>
    
    <cfreturn forecasts>
  </cffunction>
  
</cfcomponent>
