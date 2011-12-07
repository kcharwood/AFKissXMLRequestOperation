# AFKissXMLRequestOperation

AFKissXMLRequestOperation is an extension for [AFNetworking](http://github.com/AFNetworking/AFNetworking/) that provides an interface to parse XML using [KissXML](https://github.com/robbiehanson/KissXML)

This is still in early stages of development, so proceed with caution when using this in a production application. Any bug reports, feature requests, or general feedback at this point would be greatly appreciated.

## Example Usage

``` objective-c
AFKissXMLRequestOperation *operation = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://legalindexes.indoff.com/sitemap.xml"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument) {
      NSLog(@"XMLDocument: %@", XMLDocument);
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument) {
      NSLog(@"Failure!");
}];

[operation start];
```

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

AFKissXMLRequestOperation is available under the MIT license. See the LICENSE file for more info.
