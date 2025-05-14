const graph = JSON.parse(`
{
  "nodes": [
    {
      "id": "umbrella/EX.xccache",
      "cache": null,
      "type": "agg",
      "checksum": "e3b0c442"
    },
    {
      "id": "wizard/Wizard",
      "cache": "hit",
      "type": null,
      "checksum": "7a350660",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/Wizard/Wizard.xcframework"
    },
    {
      "id": "wizard/WizardImpl",
      "cache": "hit",
      "type": "macro",
      "checksum": "ed826f56",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/WizardImpl/WizardImpl.macro"
    },
    {
      "id": "core-utils/DisplayKit",
      "cache": "hit",
      "type": null,
      "checksum": "7bfb7636",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/DisplayKit/DisplayKit.xcframework"
    },
    {
      "id": "core-utils/Swizzler",
      "cache": "hit",
      "type": null,
      "checksum": "a7d7d30a",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/Swizzler/Swizzler.xcframework"
    },
    {
      "id": "core-utils/CoreUtils-Wrapper",
      "cache": "hit",
      "type": null,
      "checksum": "efe9a736",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/CoreUtils-Wrapper/CoreUtils-Wrapper.xcframework"
    },
    {
      "id": "core-utils/ResourceKit",
      "cache": "hit",
      "type": null,
      "checksum": "6c7d5339",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/ResourceKit/ResourceKit.xcframework"
    },
    {
      "id": "core-utils/DebugKit",
      "cache": "missed",
      "type": null,
      "checksum": "209adb90"
    },
    {
      "id": "Moya/Moya",
      "cache": "hit",
      "type": null,
      "checksum": "c263811c",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/Moya/Moya.xcframework"
    },
    {
      "id": "Alamofire/Alamofire",
      "cache": "hit",
      "type": null,
      "checksum": "513364f8",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/Alamofire/Alamofire.xcframework"
    },
    {
      "id": "SwiftyBeaver/SwiftyBeaver",
      "cache": "missed",
      "type": null,
      "checksum": "8cba041"
    },
    {
      "id": "KingfisherWebP/KingfisherWebP",
      "cache": "hit",
      "type": null,
      "checksum": "dccea7e",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/KingfisherWebP/KingfisherWebP.xcframework"
    },
    {
      "id": "KingfisherWebP/KingfisherWebP-ObjC",
      "cache": "hit",
      "type": null,
      "checksum": "dccea7e",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/KingfisherWebP-ObjC/KingfisherWebP-ObjC.xcframework"
    },
    {
      "id": "libwebp-Xcode/libwebp",
      "cache": "hit",
      "type": null,
      "checksum": "0d60654",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/libwebp/libwebp.xcframework"
    },
    {
      "id": "Kingfisher/Kingfisher",
      "cache": "hit",
      "type": null,
      "checksum": "7deda23b",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/Kingfisher/Kingfisher.xcframework"
    },
    {
      "id": "SnapKit/SnapKit",
      "cache": "hit",
      "type": null,
      "checksum": "2842e6e",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/SnapKit/SnapKit.xcframework"
    },
    {
      "id": "SDWebImage/SDWebImage",
      "cache": "hit",
      "type": null,
      "checksum": "cac9a55a",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/SDWebImage/SDWebImage.xcframework"
    },
    {
      "id": "firebase-ios-sdk/FirebaseCrashlytics",
      "cache": "missed",
      "type": null,
      "checksum": "fbd463894a"
    },
    {
      "id": "nanopb/nanopb",
      "cache": "hit",
      "type": null,
      "checksum": "b7e1104",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/nanopb/nanopb.xcframework"
    },
    {
      "id": "promises/FBLPromises",
      "cache": "hit",
      "type": null,
      "checksum": "540318e",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FBLPromises/FBLPromises.xcframework"
    },
    {
      "id": "GoogleUtilities/GoogleUtilities-Environment",
      "cache": "hit",
      "type": null,
      "checksum": "60da361",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/GoogleUtilities-Environment/GoogleUtilities-Environment.xcframework"
    },
    {
      "id": "GoogleUtilities/third-party-IsAppEncrypted",
      "cache": "hit",
      "type": null,
      "checksum": "60da361",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/third-party-IsAppEncrypted/third-party-IsAppEncrypted.xcframework"
    },
    {
      "id": "GoogleDataTransport/GoogleDataTransport",
      "cache": "hit",
      "type": null,
      "checksum": "617af07",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/GoogleDataTransport/GoogleDataTransport.xcframework"
    },
    {
      "id": "firebase-ios-sdk/FirebaseCrashlyticsSwift",
      "cache": "missed",
      "type": null,
      "checksum": "fbd463894a"
    },
    {
      "id": "firebase-ios-sdk/FirebaseRemoteConfigInterop",
      "cache": "hit",
      "type": null,
      "checksum": "fbd463894a",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FirebaseRemoteConfigInterop/FirebaseRemoteConfigInterop.xcframework"
    },
    {
      "id": "firebase-ios-sdk/FirebaseSessions",
      "cache": "missed",
      "type": null,
      "checksum": "fbd463894a"
    },
    {
      "id": "GoogleUtilities/GoogleUtilities-UserDefaults",
      "cache": "missed",
      "type": null,
      "checksum": "60da361"
    },
    {
      "id": "GoogleUtilities/GoogleUtilities-Logger",
      "cache": "missed",
      "type": null,
      "checksum": "60da361"
    },
    {
      "id": "promises/Promises",
      "cache": "hit",
      "type": null,
      "checksum": "540318e",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/Promises/Promises.xcframework"
    },
    {
      "id": "firebase-ios-sdk/FirebaseSessionsObjC",
      "cache": "missed",
      "type": null,
      "checksum": "fbd463894a"
    },
    {
      "id": "firebase-ios-sdk/FirebaseCoreExtension",
      "cache": "hit",
      "type": null,
      "checksum": "fbd463894a",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FirebaseCoreExtension/FirebaseCoreExtension.xcframework"
    },
    {
      "id": "firebase-ios-sdk/FirebaseCore",
      "cache": "missed",
      "type": null,
      "checksum": "fbd463894a"
    },
    {
      "id": "firebase-ios-sdk/FirebaseCoreInternal",
      "cache": "hit",
      "type": null,
      "checksum": "fbd463894a",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FirebaseCoreInternal/FirebaseCoreInternal.xcframework"
    },
    {
      "id": "GoogleUtilities/GoogleUtilities-NSData",
      "cache": "hit",
      "type": null,
      "checksum": "60da361",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/GoogleUtilities-NSData/GoogleUtilities-NSData.xcframework"
    },
    {
      "id": "firebase-ios-sdk/Firebase",
      "cache": "hit",
      "type": null,
      "checksum": "fbd463894a",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/Firebase/Firebase.xcframework"
    },
    {
      "id": "firebase-ios-sdk/FirebaseInstallations",
      "cache": "missed",
      "type": null,
      "checksum": "fbd463894a"
    },
    {
      "id": "facebook-ios-sdk/FacebookLogin",
      "cache": "hit",
      "type": null,
      "checksum": "c3d367656",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FacebookLogin/FacebookLogin.xcframework"
    },
    {
      "id": "facebook-ios-sdk/FBSDKLoginKit",
      "cache": "hit",
      "type": null,
      "checksum": "c3d367656",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FBSDKLoginKit/FBSDKLoginKit.xcframework"
    },
    {
      "id": "facebook-ios-sdk/FBSDKCoreKit",
      "cache": "hit",
      "type": null,
      "checksum": "c3d367656",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FBSDKCoreKit/FBSDKCoreKit.xcframework"
    },
    {
      "id": "facebook-ios-sdk/FacebookCore",
      "cache": "hit",
      "type": null,
      "checksum": "c3d367656",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FacebookCore/FacebookCore.xcframework"
    },
    {
      "id": "facebook-ios-sdk/LegacyCoreKit",
      "cache": "hit",
      "type": null,
      "checksum": "c3d367656",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/LegacyCoreKit/LegacyCoreKit.xcframework"
    },
    {
      "id": "facebook-ios-sdk/FBSDKCoreKit_Basics",
      "cache": "hit",
      "type": null,
      "checksum": "c3d367656",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/FBSDKCoreKit_Basics/FBSDKCoreKit_Basics.xcframework"
    },
    {
      "id": "ios-maps-sdk/GoogleMapsTarget",
      "cache": "hit",
      "type": null,
      "checksum": "02f8f14",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/GoogleMapsTarget/GoogleMapsTarget.xcframework"
    },
    {
      "id": "ios-maps-sdk/GoogleMaps",
      "cache": "hit",
      "type": null,
      "checksum": "02f8f14",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/GoogleMaps/GoogleMaps.xcframework"
    },
    {
      "id": "umbrella/EXTests.xccache",
      "cache": null,
      "type": "agg",
      "checksum": "e3b0c442"
    },
    {
      "id": "core-utils/TestKit",
      "cache": "hit",
      "type": null,
      "checksum": "0b8c8e8d",
      "binary": "https://github.com/trinhngocthuyen/xccache/tree/main/examples/xccache/packages/umbrella/binaries/TestKit/TestKit.xcframework"
    }
  ],
  "edges": [
    {
      "source": "umbrella/EX.xccache",
      "target": "SwiftyBeaver/SwiftyBeaver"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "Moya/Moya"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "ios-maps-sdk/GoogleMapsTarget"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "facebook-ios-sdk/FacebookLogin"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "firebase-ios-sdk/FirebaseCrashlytics"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "SDWebImage/SDWebImage"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "SnapKit/SnapKit"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "KingfisherWebP/KingfisherWebP"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "core-utils/DebugKit"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "core-utils/ResourceKit"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "core-utils/Swizzler"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "core-utils/DisplayKit"
    },
    {
      "source": "umbrella/EX.xccache",
      "target": "wizard/Wizard"
    },
    {
      "source": "wizard/Wizard",
      "target": "wizard/WizardImpl"
    },
    {
      "source": "core-utils/DisplayKit",
      "target": "wizard/Wizard"
    },
    {
      "source": "core-utils/Swizzler",
      "target": "core-utils/CoreUtils-Wrapper"
    },
    {
      "source": "core-utils/ResourceKit",
      "target": "core-utils/CoreUtils-Wrapper"
    },
    {
      "source": "core-utils/DebugKit",
      "target": "core-utils/CoreUtils-Wrapper"
    },
    {
      "source": "core-utils/DebugKit",
      "target": "core-utils/Swizzler"
    },
    {
      "source": "core-utils/DebugKit",
      "target": "SwiftyBeaver/SwiftyBeaver"
    },
    {
      "source": "core-utils/DebugKit",
      "target": "Moya/Moya"
    },
    {
      "source": "Moya/Moya",
      "target": "Alamofire/Alamofire"
    },
    {
      "source": "KingfisherWebP/KingfisherWebP",
      "target": "Kingfisher/Kingfisher"
    },
    {
      "source": "KingfisherWebP/KingfisherWebP",
      "target": "KingfisherWebP/KingfisherWebP-ObjC"
    },
    {
      "source": "KingfisherWebP/KingfisherWebP-ObjC",
      "target": "libwebp-Xcode/libwebp"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "firebase-ios-sdk/FirebaseCore"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "firebase-ios-sdk/FirebaseInstallations"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "firebase-ios-sdk/FirebaseSessions"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "firebase-ios-sdk/FirebaseRemoteConfigInterop"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "firebase-ios-sdk/FirebaseCrashlyticsSwift"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "GoogleDataTransport/GoogleDataTransport"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "GoogleUtilities/GoogleUtilities-Environment"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "promises/FBLPromises"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlytics",
      "target": "nanopb/nanopb"
    },
    {
      "source": "GoogleUtilities/GoogleUtilities-Environment",
      "target": "GoogleUtilities/third-party-IsAppEncrypted"
    },
    {
      "source": "GoogleDataTransport/GoogleDataTransport",
      "target": "nanopb/nanopb"
    },
    {
      "source": "GoogleDataTransport/GoogleDataTransport",
      "target": "promises/FBLPromises"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCrashlyticsSwift",
      "target": "firebase-ios-sdk/FirebaseRemoteConfigInterop"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessions",
      "target": "firebase-ios-sdk/FirebaseCore"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessions",
      "target": "firebase-ios-sdk/FirebaseInstallations"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessions",
      "target": "firebase-ios-sdk/FirebaseCoreExtension"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessions",
      "target": "firebase-ios-sdk/FirebaseSessionsObjC"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessions",
      "target": "promises/Promises"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessions",
      "target": "GoogleDataTransport/GoogleDataTransport"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessions",
      "target": "GoogleUtilities/GoogleUtilities-Environment"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessions",
      "target": "GoogleUtilities/GoogleUtilities-UserDefaults"
    },
    {
      "source": "GoogleUtilities/GoogleUtilities-UserDefaults",
      "target": "GoogleUtilities/GoogleUtilities-Logger"
    },
    {
      "source": "GoogleUtilities/GoogleUtilities-Logger",
      "target": "GoogleUtilities/GoogleUtilities-Environment"
    },
    {
      "source": "promises/Promises",
      "target": "promises/FBLPromises"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessionsObjC",
      "target": "firebase-ios-sdk/FirebaseCore"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessionsObjC",
      "target": "firebase-ios-sdk/FirebaseCoreExtension"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessionsObjC",
      "target": "GoogleUtilities/GoogleUtilities-Environment"
    },
    {
      "source": "firebase-ios-sdk/FirebaseSessionsObjC",
      "target": "nanopb/nanopb"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCore",
      "target": "firebase-ios-sdk/Firebase"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCore",
      "target": "firebase-ios-sdk/FirebaseCoreInternal"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCore",
      "target": "GoogleUtilities/GoogleUtilities-Environment"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCore",
      "target": "GoogleUtilities/GoogleUtilities-Logger"
    },
    {
      "source": "firebase-ios-sdk/FirebaseCoreInternal",
      "target": "GoogleUtilities/GoogleUtilities-NSData"
    },
    {
      "source": "firebase-ios-sdk/FirebaseInstallations",
      "target": "firebase-ios-sdk/FirebaseCore"
    },
    {
      "source": "firebase-ios-sdk/FirebaseInstallations",
      "target": "promises/FBLPromises"
    },
    {
      "source": "firebase-ios-sdk/FirebaseInstallations",
      "target": "GoogleUtilities/GoogleUtilities-Environment"
    },
    {
      "source": "firebase-ios-sdk/FirebaseInstallations",
      "target": "GoogleUtilities/GoogleUtilities-UserDefaults"
    },
    {
      "source": "facebook-ios-sdk/FacebookLogin",
      "target": "facebook-ios-sdk/FacebookCore"
    },
    {
      "source": "facebook-ios-sdk/FacebookLogin",
      "target": "facebook-ios-sdk/FBSDKLoginKit"
    },
    {
      "source": "facebook-ios-sdk/FBSDKLoginKit",
      "target": "facebook-ios-sdk/FBSDKCoreKit"
    },
    {
      "source": "facebook-ios-sdk/FBSDKCoreKit",
      "target": "facebook-ios-sdk/LegacyCoreKit"
    },
    {
      "source": "facebook-ios-sdk/FBSDKCoreKit",
      "target": "facebook-ios-sdk/FacebookCore"
    },
    {
      "source": "facebook-ios-sdk/FacebookCore",
      "target": "facebook-ios-sdk/LegacyCoreKit"
    },
    {
      "source": "facebook-ios-sdk/LegacyCoreKit",
      "target": "facebook-ios-sdk/FBSDKCoreKit_Basics"
    },
    {
      "source": "ios-maps-sdk/GoogleMapsTarget",
      "target": "ios-maps-sdk/GoogleMaps"
    },
    {
      "source": "umbrella/EXTests.xccache",
      "target": "core-utils/TestKit"
    }
  ]
}
`);

// ------------------------------------------------

const COLORS = {
  'hit': '#339966',
  'missed': '#ff6f00',
  'ignored': '#888',
  'NA': '#888',
}
const cy = cytoscape({
  container: $('#cy'),
  elements: ([...graph.nodes, ...graph.edges]).map(x => ({data: x})),
  style: [
    {
      selector: 'node',
      style: {
        'label': (e) => e.id().split("/")[1],
        'color': '#fff',
        'text-valign': 'center',
        'text-halign': 'center',
        'font-size': '14px',
        'shape': 'roundrectangle',
        'width': (e) => Math.max(50, e.id().split('/')[1].length * 8),
        'background-color': (e) => COLORS[e.data('cache') || 'NA'],
      }
    },
    {
      selector: 'node:selected',
      style: {
        'font-weight': 'bold',
        'border-width': 3,
        'border-color': '#333',
      }
    },
    {
      selector: 'node[type="agg"]',
      style: {
        'background-color': '#333',
      }
    },
    {
      selector: 'edge',
      style: {
        'width': 1,
        'target-arrow-shape': 'triangle',
        'curve-style': 'bezier',
        'line-color': '#ccc',
        'target-arrow-color': '#ccc',
      }
    },
  ],
  layout: {
    name: 'fcose',
    animationDuration: 200,
    nodeRepulsion: 10000,
    idealEdgeLength: 120,
    gravity: 0.25,
  }
});

cy.on('select', 'node', function(event) {
  const node = event.target;
  node.displayDetails();
  node.neighborhood().add(node).focus();
});

cy.on('tap', function(event) {
  if (event.target == cy) {
    $('.node-info').css('display', 'none');
    cy.elements().animateStyle({'opacity': 1, 'line-color': '#ccc', 'target-arrow-color': '#ccc'});
  }
});

// -----------------------------------------------------------------

cytoscape('collection', 'animateStyle', function(style) {
  this.animate({style: style, duration: 200, easing: 'ease-out'})
});
cytoscape('collection', 'focus', function() {
  this.animateStyle({'opacity': 1, 'line-color': '#666', 'target-arrow-color': '#666'});
  cy.elements().not(this).animateStyle({'opacity': 0.15, 'line-color': '#ccc', 'target-arrow-color': '#ccc'});
});
cytoscape('collection', 'displayDetails', function() {
  $('.node-info').css('display', 'block');
  const info = $('.node-info .info');
  info.find('.target').html(this.id());
  info.find('.checksum').html(this.data('checksum') || 'NA');
  info.find('.binary')
    .html((this.data('binary') || 'NA').split('/').slice(-1))
    .attr({'href': this.data('binary') || ''});
  info.find('.others').html(`Node degree: ${this.degree()} (${this.indegree()} in, ${this.outdegree()} out)`);
});
