from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, PrivateSubnet, PublicSubnet, InternetGateway, NATGateway, ElbApplicationLoadBalancer
from diagrams.onprem.compute import Server
from diagrams.aws.storage import SimpleStorageServiceS3Bucket
from diagrams.aws.database import RDSPostgresqlInstance

# Variables
title = "VPC with 1 public subnet for the TFE server"
outformat = "png"
filename = "diagram-tfe_external_disk"
direction = "TB"


with Diagram(
    name=title,
    direction=direction,
    filename=filename,
    outformat=outformat,
) as diag:
    # Non Clustered
    user = Server("user")

    # Cluster 
    with Cluster("aws"):
        bucket_files = SimpleStorageServiceS3Bucket("TFE bucket")
        with Cluster("vpc"):
            igw_gateway = InternetGateway("igw")
    
                            
            with Cluster("Availability Zone: eu-north-1a \n\n  "):
                # Subcluster 
                with Cluster("subnet_public1"):
                     ec2_client_server = EC2("client machine \n\(Proxy Server &\nNetwork Mirror\)")
                     ec2_tfe_server = EC2("TFE_server")

    # Diagram

    user >> bucket_files 

    user >> ec2_tfe_server
     
    ec2_tfe_server >> [bucket_files]

diag
