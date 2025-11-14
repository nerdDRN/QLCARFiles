# CAR Viewer

A macOS application to view and explore Assets.car files from iOS and macOS applications.

## Features

- Browse assets from Assets.car files
- View images with different scales (@1x, @2x, @3x)
- View colors with light/dark appearance variants
- View data assets including PDFs
- Export assets to disk

## Credits

This project is inspired by and builds upon the excellent work of [Timac](https://github.com/Timac):

- [Reverse Engineering the .car File Format](https://blog.timac.org/2018/1018-reverse-engineering-the-car-file-format/) - Deep dive into understanding the CAR file structure
- [QuickLook Plugin to Visualize .car Files](https://blog.timac.org/2018/1112-quicklook-plugin-to-visualize-car-files/) - Original implementation for visualizing CAR files

Special thanks to Timac for the groundbreaking research and code that made this project possible.

## Requirements

- macOS 15.0+
- Xcode 16.0+

## Build

1. Clone the repository
2. Open `QLCARFilesApp.xcodeproj` in Xcode
3. Build and run

## Usage

1. Launch the app
2. Open an Assets.car file (⌘O)
3. Browse and explore the assets
4. Export individual assets or all assets

## License

MIT License - see [LICENSE](LICENSE) file for details.
