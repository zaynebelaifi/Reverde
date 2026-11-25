import os
os.environ["EUREKA_ENABLED"] = "false"
from fastapi.testclient import TestClient
from main import app


def test_hello():
    with TestClient(app) as client:
        response = client.get('/hello')
        assert response.status_code == 200
        assert response.json()['status'] == 'UP'
        assert response.json()['service'] == 'analytics-service'


def test_health():
    with TestClient(app) as client:
        assert client.get('/health').json() == {'status': 'UP'}


def test_openapi_server_matches_gateway_and_direct_access():
    with TestClient(app) as client:
        gateway = client.get('/openapi.json', headers={'X-Forwarded-Prefix': '/analytics'}).json()
        assert gateway['servers'] == [{'url': '/analytics'}]
        assert gateway['components']['schemas']['ServiceIdentity']['properties']['port']['type'] == 'integer'
        assert client.get('/openapi.json').json()['servers'] == [{'url': '/'}]
