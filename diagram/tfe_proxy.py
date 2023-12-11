from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.compute import Server
from diagrams.onprem.network import Internet
from diagrams.onprem.network import Nginx

# Variables
outformat = "png"
filename = "tfe_proxy"
direction = "TB"


with Diagram(
    direction=direction,
    filename=filename,
    outformat=outformat,
) as diag:
    # Non Clustered
    user = Server("client")
    proxy = Server("MITMproxy")
    tfe = Server("TFE server")
    internet = Internet("internet")
    terraform_io = Nginx("Terraform.io")
 
    # Diagram
    user >> tfe >> proxy >> internet >> terraform_io

diag