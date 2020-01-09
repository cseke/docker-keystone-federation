import requests
js = {
    "auth": {
        "identity": {
            "methods": [
                "token"
            ],
            "token": {
                "id": "<--unscoped_token_goes_here-->"
            }
        },
        "scope": {
            "project": {
                "id": "<--id_of_the_federation_project-->"
            }
        }
    }
}
res = requests.post('http://localhost:5000/v3/auth/tokens', json=js)
print(res.json())
