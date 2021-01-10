<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DataCollection.aspx.cs" Inherits="VersusCovid.DataCollection" %>
<!DOCTYPE html>

<%@ Import Namespace="System.IO"%>
<%@ Import Namespace="System.Net"%>
<%@ Import Namespace="System.Text.Json"%>
<%@ Import Namespace="VersusCovid"%>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Data Collection</title>
    <link rel="stylesheet" href="style.css" />
</head>
<script>
    function nav_open() {
        document.getElementById("mob_nav").style.display = "block";
    }
    function nav_close() {
        document.getElementById('mob_nav').style.display = "none";
    }
</script>

<body class="statistics">
    <div id="mob_header">
        <button onclick="nav_open()">=</button>
        <div id="logo"></div>
        <div id="mob_nav">
            <button onclick="nav_close()">X</button>
            <a href="home.html">Home page</a>
            <a href="datacollection.aspx">Statistics</a>
            <a href="takeaction.html">Take actions</a>
        </div>
    </div>
    <div id="body">
        <!--header-->
        <header>
            <div id="logo"></div>
            <nav>
                <img id="clip" src="../Images/clip2.png" />
                <a href="takeaction.html" id="action_label">Take actions</a>
                <a href="datacollection.aspx" id="stat_label">Statistics</a>
                <a href="home.html" id="home_label">Home page</a>
            </nav>
        </header>
        <!--main-->
        <main>
            <div class="paper">
                <h1>COVID-19 tracker</h1>
                <div class="form">
                    <form method="get" runat="server">
                        <% 
                            //Varibles
                            int totalCases,totalDeaths,totalCasesDate,totalDeathsDate,casesToday,deathsToday,casesDate,deathsDate,startCountingCases;
                            totalCases = totalDeaths = totalCasesDate = totalDeathsDate = casesToday = deathsToday = casesDate = deathsDate = startCountingCases = 0;
                            string Country = Request.QueryString["country"];
                            Directory.CreateDirectory(Path.GetTempPath()+"\\VersusCovid19Group8"); //Creating folder for the json file
                            string fileLocation = Path.GetTempPath()+"/VersusCovid19Group8/file.json"; //Location of the json file

                            //Cheking if json file is older that 1 hour
                            DateTime dateTimeToday = DateTime.Now;
                            DateTime fileCreatedDate = File.GetLastWriteTime(fileLocation);
                            string dateCreated= fileCreatedDate.ToString("d/M/H");
                            string dateToday = dateTimeToday.ToString("d/M/H");
                            if (File.Exists(fileLocation) == false || dateCreated != dateToday)
                            {
                                WebClient myWebClient = new WebClient();
                                myWebClient.DownloadFile("https://opendata.ecdc.europa.eu/covid19/casedistribution/json/", fileLocation);//downloading json
                            }

                            //string json = File.ReadAllText(fileLocation);
                            Records allData = JsonSerializer.Deserialize<Records>(File.ReadAllText(fileLocation));

                            string date = Request.QueryString["date"];
                            dateToday = dateTimeToday.ToString("dd'/'MM'/'yyyy");
                            string noDataYet = "";

                            if(allData.records[0].dateRep!=dateToday)//Show yesterday's statistics if today's has not been published yet. 
                            {
                                dateTimeToday = dateTimeToday.AddDays(-1);
                                dateToday = dateTimeToday.ToString("dd'/'MM'/'yyyy");
                                noDataYet = "The actual data have still not been published. Displaying data for "+ dateToday+".";
                            }
                            if(Country == null)//Default country
                            {
                                Country = "Finland";
                            }
                            if(date == null)//Default date
                            {
                                date = dateToday;
                            }

                            DateTime dateTime = Convert.ToDateTime(date);
                            date = dateTime.ToString("dd'/'MM'/'yyyy");
                            string maxDate = dateTimeToday.ToString("yyyy'-'MM'-'dd");
                            string valueDate = dateTime.ToString("yyyy'-'MM'-'dd");

                            for (int i = 0; i < allData.records.Length; i++)//Start searching
                            {
                                if (allData.records[i].countriesAndTerritories == Country) //Total stat
                                {
                                    totalCases = allData.records[i].cases + totalCases;
                                    totalDeaths = allData.records[i].deaths + totalDeaths;
                                }
                                if (allData.records[i].countriesAndTerritories == Country && allData.records[i].dateRep == dateToday) //Today stat
                                {
                                    casesToday = allData.records[i].cases;
                                    deathsToday = allData.records[i].deaths;
                                }
                                if (allData.records[i].countriesAndTerritories == Country && allData.records[i].dateRep == date) //Date stat
                                {
                                    casesDate = allData.records[i].cases;
                                    deathsDate = allData.records[i].deaths;
                                }
                                if (allData.records[i].countriesAndTerritories == Country && allData.records[i].dateRep == date) //Total date stat part1
                                {
                                    totalCasesDate = allData.records[i].cases + totalCasesDate;
                                    totalDeathsDate = allData.records[i].deaths + totalDeathsDate;
                                    startCountingCases = 1;
                                }
                                if (allData.records[i].countriesAndTerritories == Country && allData.records[i].dateRep != date && startCountingCases == 1) //Total date stat part 2
                                {
                                    totalCasesDate = allData.records[i].cases + totalCasesDate;
                                    totalDeathsDate = allData.records[i].deaths + totalDeathsDate;

                                }
                            }
                    %>
                        <label for="date">Date:</label>
                        <input required type="date" id="date" name="date" max="<%Response.Write(maxDate);%>" value="<%Response.Write(valueDate); %>">
                        <label for="country">Country:</label>
                        <select name="country" id="country">
                            <%
                            for (int i = 0; i < allData.records.Length; i++)//Create list of countries
                            {
                                if (allData.records[i].dateRep == dateToday & allData.records[i].countriesAndTerritories == Country)//saving selected country
                                {
                                    Response.Write("<option selected value=" + allData.records[i].countriesAndTerritories + ">" + allData.records[i].countriesAndTerritories + "</option>");

                                }else if(allData.records[i].dateRep == dateToday)
                                {
                                    Response.Write("<option value=" + allData.records[i].countriesAndTerritories + ">" + allData.records[i].countriesAndTerritories + "</option>");
                                }
                            }
                            %>
                        </select>
                </div>
                <button type="submit">Search</button>
                <h3><%Response.Write(noDataYet); %></h3>
                <!--if today's data have not yet been published, a notice is displayed-->
                <div class="country_block">
                    <h2>Total Confirmed Corona cases in <%Response.Write(Country); %>:</h2>
                    <div class="counter_cases">
                        <p>Cases</p>
                        <p id="cases_c"><%Response.Write(totalCases); %></p>
                        <p id='day_cases'>+ <%Response.Write(casesToday); %></p>
                    </div>
                    <div class="counter">
                        <p>Deaths</p>
                        <p id="deaths_c"><%Response.Write(totalDeaths); %></p>
                        <p id='day_deaths'>+ <%Response.Write(deathsToday); %></p>
                    </div>
                </div>
                <div class="area_block">
                    <h2>Total Confirmed Corona cases in <%Response.Write(Country + " on " + date); %>:</h2>
                    <div class="counter_cases">
                        <p>Cases</p>
                        <p id="cases_c"><%Response.Write(totalCasesDate); %></p>
                        <p id='day_cases'>+ <%Response.Write(casesDate); %></p>
                    </div>
                    <div class="counter">
                        <p>Deaths</p>
                        <p id="deaths_c"><%Response.Write(totalDeathsDate); %></p>
                        <p id='day_deaths'>+ <%Response.Write(deathsDate); %></p>
                    </div>
                </div>
                </form>
            </div>

        </main>

        <!--footer-->
        <footer>
            <p>Please note that we cache the data file on your PC in the Temporary folder.</p>
            <p>This application is created by group 8</p>
        </footer>
    </div>
</body>

</html>