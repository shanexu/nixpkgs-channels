{ stdenv, buildPythonPackage, fetchPypi, python
, google_api_core, grpcio, pytest, mock, setuptools }:

buildPythonPackage rec {
  pname = "google-cloud-core";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0vfhvpiiigfldi3vb0730w13md1c90irpdx5kypmnfszrrzg7q2a";
  };

  propagatedBuildInputs = [ google_api_core grpcio setuptools ];
  checkInputs = [ pytest mock ];

  checkPhase = ''
    cd tests
    ${python.interpreter} -m unittest discover
  '';

  meta = with stdenv.lib; {
    description = "API Client library for Google Cloud: Core Helpers";
    homepage = "https://github.com/GoogleCloudPlatform/google-cloud-python";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
