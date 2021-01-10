using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace VersusCovid
{
    public class Records
    {
        public DataRecords[] records { get; set; }
    }
    public class DataRecords
    {
        public string countriesAndTerritories { get; set; }
        public string dateRep { get; set; }
        public int cases { get; set; }
        public int deaths { get; set; }

    }
    public partial class DataCollection : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}