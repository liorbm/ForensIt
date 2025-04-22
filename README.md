# ForensIt -  File Analysis Tool

![ForensIt Banner](https://img.shields.io/badge/ForensIt-v1.00-blue)
![License](https://img.shields.io/badge/License-MIT-green)

ForensIt is a comprehensive file analysis tool that automates the process of analyzing files and memory dumps using various tools. It provides a user-friendly interface for performing analysis and generates detailed reports of the findings.

![ForensIt-Screenshot-Example](https://github.com/user-attachments/assets/0640c871-dc03-46c9-980b-872254192ac0)

## Features

- **Multiple Forensic Tools Integration**
  - Volatility
  - Foremost
  - Binwalk
  - Bulk-extractor
  - Strings

- **Automated Analysis**
  - Process list extraction
  - Network connection analysis
  - Registry information extraction
  - Human-readable string extraction
  - File carving capabilities

- **Smart File Location**
  - System-wide file search
  - Interactive file selection
  - Multiple file path support

- **Comprehensive Reporting**
  - Detailed analysis statistics
  - Extracted files count
  - Network information
  - Volatility analysis results
  - Timestamped reports

## Installation

1. Clone the repository:
```bash
git clone https://github.com/liorbm/ForensIt.git
cd ForensIt
```

2. Make the script executable:
```bash
chmod +x ForensIt.sh
```

3. Run as root:
```bash
sudo ./ForensIt.sh
```

## Usage

1. Run the script with root privileges
2. Enter the filename you want to analyze
3. Select the file path from the list of found files
4. Choose the analysis tools you want to use
5. Review the generated report

## Analysis Options

The tool provides several analysis options:

1. **Foremost** - File carving and recovery
2. **Binwalk** - File signature analysis
3. **Bulk-extractor** - Feature extraction
4. **Strings** - Human-readable string extraction
5. **Volatility** - Memory analysis
6. **All Tools** - Comprehensive analysis using all tools

## Output

The tool generates:
- A timestamped report directory
- Extracted files and data
- Analysis statistics
- Network information (if available)
- Volatility analysis results

## Requirements

- Linux-based operating system
- Root privileges
- Internet connection (for initial setup)
- Required packages:
  - binwalk
  - foremost
  - bulk-extractor
  - binutils (for strings)
  - figlet (for banner display)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

- **Lior Biam** - [GitHub Profile](https://github.com/liorbm)

## Acknowledgments

- Volatility Foundation for the Volatility framework
- All the open-source tools used in this project
- The digital forensics community for their contributions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you find this tool helpful, consider starring the repository and sharing it with others! 
