//
//  IGRMainViewController.m
//  InstaFilters
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

@import IGRFilterCombine;

#import "ViewController.h"
#import "IGRFilterbarCell.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                              UICollectionViewDelegate, UICollectionViewDataSource,
                              IGRFilterCombineDelegate>

@property (nonatomic, weak  ) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak  ) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IGRFilterCombine *filterCombine;

@end

static NSString * const kWorkImageNotification = @"WorkImageNotification";
#define DEMO_IMAGE [UIImage imageNamed:@"demo"]

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.filterCombine = [[IGRFilterCombine alloc] initWithDelegate:self];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(setupWorkImage:)
                          name:kWorkImageNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupDemoView];
    });
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:kWorkImageNotification object:nil];
}

#pragma mark - Private

- (void)setupDemoView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWorkImageNotification
                                                        object:DEMO_IMAGE];
}

- (UIImage *)prepareImage
{
    return self.imageView.image;
}

#pragma mark - Action

- (IBAction)onTouchGetImageButton:(UIBarButtonItem *)sender
{
    UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select image", @"")
                                                                   message:@""
                                                            preferredStyle:style];
    
    alert.popoverPresentationController.barButtonItem = sender;
    
    __weak typeof(self) weak = self;
    void(^completeActionBlock)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType type) {
        UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
        pickerView.delegate = weak;
        [pickerView setSourceType:type];
        [self presentViewController:pickerView animated:YES completion:nil];
    };
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"From Library", @"")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       completeActionBlock(UIImagePickerControllerSourceTypePhotoLibrary);
                                                   }];
    [alert addAction:action];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"From Camera", @"")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             completeActionBlock(UIImagePickerControllerSourceTypeCamera);
                                                         }];
    [alert addAction:cameraAction];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
				
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onTouchShareButton:(UIBarButtonItem *)sender
{
    UIImage *image = [self prepareImage];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[image]
                                                                      applicationActivities:nil];
    avc.popoverPresentationController.barButtonItem = sender;
    avc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    [self presentViewController:avc animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.filterCombine.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IGRFilterbarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IGRFilterbarCell"
                                                                       forIndexPath:indexPath];
    
    cell.icon.image = [self.filterCombine filteredPreviewImageAtIndex:indexPath.row];
    cell.title.text = [self.filterCombine filtereNameAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat borderOffset = [self igr_borderOffsetFromFiltersbar:collectionView];
    
    UICollectionViewLayoutAttributes *attrs = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frame = attrs.frame;
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(0.0, -borderOffset, 0.0, -borderOffset));
    [collectionView scrollRectToVisible:frame animated:YES];
    
    self.imageView.image = [self.filterCombine filteredImageAtIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:NO];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(nonnull UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return CGSizeMake(100.0, 100.0);
}

- (CGFloat)igr_borderOffsetFromFiltersbar:(UICollectionView *)collectionView
{
    return collectionView.frame.size.height * 0.5;
}

#pragma mark - IGRFilterCombineDelegate

- (CGSize)previewSize
{
    return CGSizeMake(70.0, 70.0);
}

#pragma mark - NSNotificationCenter

- (void)setupWorkImage:(NSNotification *)notification
{
    NSAssert([notification.object isKindOfClass:[UIImage class]], @"Image only allowed!");
    UIImage *image = notification.object;
    
    __weak typeof(self) weak = self;
    [self.filterCombine setImage:image
                      completion:^(UIImage * _Nullable processedImage, NSUInteger idx) {
                          NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                          if ([[weak.collectionView indexPathsForSelectedItems] containsObject:indexPath])
                          {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  weak.imageView.image = processedImage;
                              });
                          }
                      }
                         preview:^(UIImage * _Nullable processedImage, NSUInteger idx) {
                             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                             if ([[weak.collectionView indexPathsForVisibleItems] containsObject:indexPath])
                             {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     IGRFilterbarCell *cell = (IGRFilterbarCell *)[weak.collectionView cellForItemAtIndexPath:indexPath];
                                     cell.icon.image = processedImage;
                                 });
                             }
                         }];
    
    self.imageView.image = image;
    [self.collectionView reloadData];
}

#pragma mark - PickerDelegates

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *img = [info valueForKey:UIImagePickerControllerOriginalImage];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWorkImageNotification
                                                        object:img];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
