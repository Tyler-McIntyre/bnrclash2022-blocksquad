import 'package:flutter/material.dart';

// ----------------------------------------------------------------------------
// Campaign Header Image
// ----------------------------------------------------------------------------
class CampaignImage extends StatelessWidget {
  final String imageURL;

  const CampaignImage(this.imageURL);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1,
        ),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FittedBox(
            fit: BoxFit.fill,
            child: Image.network(
              imageURL,
              width: 585,
              height: 230,
              fit: BoxFit.cover,
            )),
      )
    );
  }
}