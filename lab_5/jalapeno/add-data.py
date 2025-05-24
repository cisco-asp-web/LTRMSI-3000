# Script to create ArangoDB collections and upload data
# requires https://pypi.org/project/python-arango/

from arango import ArangoClient
import json
import argparse

# Database connection settings
user = "root"
pw = "jalapeno"
dbname = "jalapeno"

# Connect to ArangoDB
client = ArangoClient(hosts='http://198.18.128.101:30852')
db = client.db(dbname, username=user, password=pw)

def parse_args():
    """
    Parse command line arguments
    Returns:
        args: Parsed command line arguments
    """
    parser = argparse.ArgumentParser(description='Create collections and upload data to ArangoDB')
    parser.add_argument('-d', '--data', nargs='+', 
                       choices=['fabric-node', 'fabric-edge', 'hosts', 'all'],
                       help='Specify which data to upload: fabric-node, fabric-edge, hosts, or all')
    return parser.parse_args()

def upload_fabric_nodes(db, file_path):
    """
    Create fabric_node collection and upload data from fabric-node.json
    Args:
        db: ArangoDB database connection
        file_path: Path to the fabric-node.json file
    """
    try:
        # Read the data from JSON file
        with open(file_path, 'r') as f:
            node_data = json.load(f)
        
        # Create collection if it doesn't exist
        if not db.has_collection('fabric_node'):
            db.create_collection('fabric_node')
            print("Created fabric_node collection")
        
        collection = db.collection('fabric_node')
        
        # AQL query to insert/update data
        aql = """
        FOR node in @nodes
            UPSERT { _key: node._key }
            INSERT node
            REPLACE node
            IN fabric_node
            RETURN NEW
        """
        
        # Execute AQL query
        db.aql.execute(aql, bind_vars={'nodes': node_data})
        print(f"Successfully inserted/updated {len(node_data)} fabric node records")
        
    except Exception as e:
        print(f"Error uploading fabric node data: {str(e)}")

def upload_hosts(db, file_path):
    """
    Create hosts collection and upload data from hosts.json
    Args:
        db: ArangoDB database connection
        file_path: Path to the hosts.json file
    """
    try:
        # Read the data from JSON file
        with open(file_path, 'r') as f:
            host_data = json.load(f)
        
        # Create collection if it doesn't exist
        if not db.has_collection('hosts'):
            db.create_collection('hosts')
            print("Created hosts collection")
        
        collection = db.collection('hosts')
        
        # AQL query to insert/update data
        aql = """
        FOR host in @hosts
            UPSERT { _key: host._key }
            INSERT host
            REPLACE host
            IN hosts
            RETURN NEW
        """
        
        # Execute AQL query
        db.aql.execute(aql, bind_vars={'hosts': host_data})
        print(f"Successfully inserted/updated {len(host_data)} host records")
        
    except Exception as e:
        print(f"Error uploading host data: {str(e)}")

def upload_fabric_edges(db, file_path):
    """
    Create fabric_edge collection and upload data from fabric-edge.json
    Args:
        db: ArangoDB database connection
        file_path: Path to the fabric-edge.json file
    """
    try:
        # Read the data from JSON file
        with open(file_path, 'r') as f:
            edge_data = json.load(f)
        
        # Create collection if it doesn't exist
        if not db.has_collection('fabric_edge'):
            db.create_collection('fabric_edge', edge=True)
            print("Created fabric_edge collection")
        
        collection = db.collection('fabric_edge')
        
        # AQL query to insert/update data
        aql = """
        FOR edge in @edges
            UPSERT { _key: edge._key }
            INSERT edge
            REPLACE edge
            IN fabric_edge
            RETURN NEW
        """
        
        # Execute AQL query
        db.aql.execute(aql, bind_vars={'edges': edge_data})
        print(f"Successfully inserted/updated {len(edge_data)} fabric edge records")
        
    except Exception as e:
        print(f"Error uploading fabric edge data: {str(e)}")


if __name__ == "__main__":
    args = parse_args()
    
    # If no arguments provided or 'all' specified, run everything
    if not args.data or 'all' in args.data:
        print("\nUploading fabric node data...")
        upload_fabric_nodes(db, "fabric-node.json")
        print("\nUploading host data...")
        upload_hosts(db, "hosts.json")
        print("\nUploading fabric edge data...")
        upload_fabric_edges(db, "fabric-edge.json")

    else:
        # Run only specified functions
        if 'fabric-node' in args.data:
            print("\nUploading fabric node data...")
            upload_fabric_nodes(db, "fabric-node.json")
        if 'hosts' in args.data:
            print("\nUploading host data...")
            upload_hosts(db, "hosts.json") 
        if 'fabric-edge' in args.data:
            print("\nUploading fabric edge data...")
            upload_fabric_edges(db, "fabric-edge.json")
