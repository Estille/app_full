import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String thumbnail;
  final double rating;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.thumbnail,
    required this.rating,
  });

  @override
  List<Object?> get props => [id, title, description, price, category, thumbnail, rating];
}
