[The Project is not served, please, enjoy forward :)]
==

# IGRFilterCombine

Replicate Instragram-style filters in Objective-C (Swift 3.0 Compatibility).

### Easy to use:
- Add image to IGRFilterCombine,
- Read filtered image at index.

[![Build Status](https://travis-ci.org/IGRSoft/IGRFilterCombine.svg)](https://travis-ci.org/IGRSoft/IGRFilterCombine)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](http://www.apple.com/ios/)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/IGRFilterCombine.svg)](https://img.shields.io/cocoapods/v/IGRFilterCombine.svg)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://opensource.org/licenses/MIT)

 ___
### Contribute to Development Goals Here: 

BTC: 16tGJzt4gJJBhBetpV6BuaWuNfxvkdkbt4

BCH: bitcoincash:qpcwefpxddjqzdpcrx6tek3uh6x9v7t8tugu30jvks

LTC: litecoin:MLZxuAdJCaW7LdM4sQuRazgdNvd8G2bdyt

___
## How It Works
It is built upon [GPUImage](https://github.com/BradLarson/GPUImage), written open sourced framework by [Brad Larson](http://stackoverflow.com/users/19679/brad-larson) that hanles low-level GPU interactions on **IGRFilterCombine**'s behalf.

The GPUImage framework is a BSD-licensed iOS library that lets you apply GPU-accelerated filters and other effects to images, live camera video, and movies. In comparison to Core Image (part of iOS 5.0), GPUImage allows you to write your own custom filters, supports deployment to iOS 4.0, and has a simpler interface. However, it currently lacks some of the more advanced features of Core Image, such as facial detection.

For massively parallel operations like processing images or live video frames, GPUs have some significant performance advantages over CPUs. On an iPhone 4, a simple image filter can be over 100 times faster to perform on the GPU than an equivalent CPU-based filter.

## Filters
- 1977
- Amaro
- Brannan
- Earlybird
- Hefe
- Hudson
- Inkwell
- Lomo
- Lord Kelvin
- Nashville
- Rise
- Sierra
- Sutro
- Toaster
- Valencia
- Walden
- Xproll

___
## Requirements

- Xcode 8.0+
- iOS 9.0+

___
## Installation

### CocoaPods

The preferred installation method is with [CocoaPods](https://cocoapods.org). Add the following to your `Podfile`:

```ruby
pod 'IGRFilterCombine'
```

### Carthage

For [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

```ogdl
github "IGRSoft/IGRFilterCombine"
```

___
## Getting Started

<details>
  <summary>Objective-C</summary>
  <p>
```objective-c
@import IGRFilterCombine;

@interface ViewController ()

@property (nonatomic, strong) IGRFilterCombine *filterCombine;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.filterCombine = [[IGRFilterCombine alloc] initWithDelegate:self];
}

- (void)setupImage:(UIImage *)image
{
    __weak typeof(self) weak = self;
    [self.filterCombine setImage:image
                      completion:^(UIImage * _Nullable processedImage, NSUInteger idx) {
                        //Process Image
                    }
                         preview:^(UIImage * _Nullable processedImage, NSUInteger idx) {
                            //Process Preview
    }];
}

- (NSString *)filtereNameAtIndex:(NSUInteger)imageIndex;
- (UIImage *)filteredImageAtIndex:(NSUInteger)imageIndex;
- (UIImage *)filteredPreviewImageAtIndex:(NSUInteger)imageIndex;

- (NSUInteger)count;

#pragma mark - IGRFilterCombineDelegate

- (CGSize)previewSize
{
    return CGSizeMake(70.0, 70.0);
}

@end
```
</p></details>
<details>
  <summary>Swift 3.0</summary>
  <p>
```swift
import IGRFilterCombine

class ViewController: UIViewController {
    fileprivate var filterCombine: IGRFilterCombine?

    override func viewDidLoad() {
        super.viewDidLoad()

        filterCombine = IGRFilterCombine(delegate: self as IGRFilterCombineDelegate)
    }

    func setupWorkImage(_ image: UIImage) {
        self.filterCombine?.setImage(image, completion: { (processedImage, idx) in
            //Process Image
        }) { (processedImage, idx) in
            //Process Preview
        }
    }

    

    self.imageView?.image = image
    self.collectionView?.reloadData()
    }
    
    // MARK: - IGRFilterCombineDelegate

    extension ViewController : IGRFilterCombineDelegate {
        func previewSize() -> CGSize {
            return CGSize(width: 70.0, height: 70.0)
        }
    }

    open func filtereName(at imageIndex: UInt) -> String

    open func filteredImage(at imageIndex: UInt) -> UIImage

    open func filteredPreviewImage(at imageIndex: UInt) -> UIImage


    open func count() -> UInt
}
```
</p></details>

> see sample Xcode project in /Demo

## TODO
 - [x] Add Filters to Images
 - [ ] Add Custom Filters

___
## Credits

`IGRFilterCombine` is owned and maintained by the [IGR Software and Vitalii Parovishnyk](https://igrsoft.com).

___
## License

`IGRFilterCombine` is MIT-licensed. We also provide an additional patent grant.
