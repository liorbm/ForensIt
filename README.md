# ForensIt - Forensic Analysis Tool

![ForensIt Banner](https://img.shields.io/badge/ForensIt-v1.00-blue)

ForensIt is a powerful file forensic analysis tool designed to help investigators analyze files and memory dumps efficiently. It provides a comprehensive suite of forensic tools and automated analysis capabilities.

## Features

- **Multiple Forensic Tools Integration**:
  - Volatility 2.6 for memory analysis
  - Foremost for file carving
  - Binwalk for file extraction
  - Bulk-extractor for bulk data extraction
  - Strings for text pattern extraction

- **Automated Analysis**:
  - Process list extraction
  - Network connection analysis
  - Registry information extraction
  - File carving capabilities
  - Human-readable string extraction

- **User-Friendly Interface**:
  - Color-coded output for better readability
  - Interactive menu system
  - Automated tool installation
  - Comprehensive reporting

## Requirements

- Linux-based operating system
- Root privileges
- Internet connection (for initial setup)
- Minimum 2GB RAM (recommended 4GB+ for large memory dumps)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/liorbm/ForensIt.git
cd ForensIt
```

2. Make the script executable:
```bash
chmod +x script.sh
```

3. Run the script as root:
```bash
sudo ./script.sh
```

## Usage

1. Run the script with root privileges
2. The script will automatically check and install required dependencies
3. Enter the filename when prompted
4. Choose from the following analysis options:
   - 1: Foremost analysis
   - 2: Binwalk analysis
   - 3: Bulk-extractor analysis
   - 4: Strings analysis
   - 5: Volatility analysis
   - 6: Run all tools

## Output

The tool creates a structured output directory (`ForensIt-Results/`) containing:
- Extracted files
- Process lists
- Network information
- Registry data
- Human-readable strings
- Comprehensive analysis report

## Report Generation

After analysis, the tool generates:
- Detailed analysis report
- Statistics about extracted data
- Network information (if available)
- Volatility analysis results
- All extracted data in a zip archive

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


## Author

- **Lior Biam** - [GitHub Profile](https://github.com/liorbm)
