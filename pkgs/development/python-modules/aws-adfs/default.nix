{ lib, buildPythonPackage, fetchPypi
, pytest, pytestrunner, pytestcov, mock, glibcLocales, lxml, boto3, requests, click, configparser }:

buildPythonPackage rec {
  pname = "aws-adfs";
  version = "1.19.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "20b2ad44d19aa494fa11cb2d1290359b3a7a0c6c8908179b4af0c9367d83e370";
  };

  # Relax version constraint
  patchPhase = ''
    sed -i 's/coverage < 4/coverage/' setup.py
  '';

  # Test suite writes files to $HOME/.aws/, or /homeless-shelter if unset
  HOME = ".";

  # Required for python3 tests, along with glibcLocales
  LC_ALL = "en_US.UTF-8";

  checkInputs = [ glibcLocales pytest pytestrunner pytestcov mock ];
  propagatedBuildInputs = [ lxml boto3 requests click configparser ];

  meta = with lib; {
    description = "Command line tool to ease aws cli authentication against ADFS";
    homepage = https://github.com/venth/aws-adfs;
    license = licenses.psfl;
    maintainers = [ maintainers.bhipple ];
  };
}
